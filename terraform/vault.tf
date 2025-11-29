resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
  depends_on = [module.eks]
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  version    = "0.28.1"

  values = [
    yamlencode({
      server = {
        replicas = 1
        resources = {
          requests = {
            memory = "256Mi"
            cpu    = "250m"
          }
          limits = {
            memory = "512Mi"
            cpu    = "500m"
          }
        }
        dataStorage = {
          enabled      = true
          size         = "10Gi"
          storageClass = "gp2"
        }
        standalone = {
          enabled = true
          config = <<-EOT
            ui = true
            listener "tcp" {
              tls_disable = 1
              address = "[::]:8200"
              cluster_address = "[::]:8201"
            }
            storage "file" {
              path = "/vault/data"
            }
          EOT
        }
        nodeSelector = {
          role = "monitoring"
        }
        tolerations = [
          {
            key      = "monitoring"
            operator = "Equal"
            value    = "true"
            effect   = "NoSchedule"
          }
        ]
      }
      ui = {
        enabled = true
        serviceType = "ClusterIP"
      }
    })
  ]

  depends_on = [module.eks]
}

resource "kubernetes_service" "vault_ui" {
  metadata {
    name      = "vault-ui-external"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
  spec {
    selector = {
      "app.kubernetes.io/name"     = "vault"
      "app.kubernetes.io/instance" = "vault"
      component                    = "server"
    }
    port {
      name        = "http"
      port        = 8200
      target_port = 8200
    }
    type = "LoadBalancer"
  }
  depends_on = [helm_release.vault]
}