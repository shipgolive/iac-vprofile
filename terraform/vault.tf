resource "kubernetes_service" "vault_ui" {
  metadata {
    name      = "vault-ui-external"
    namespace = "vault"
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
  depends_on = [module.eks]
}