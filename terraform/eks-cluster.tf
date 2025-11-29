module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.32"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    apps = {
      name           = "apps-node-group"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 4
      desired_size   = 3

      labels = {
        role = "applications"
      }
    }

    monitoring = {
      name           = "monitoring-node-group"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      labels = {
        role = "monitoring"
      }

      taints = {
        monitoring = {
          key    = "monitoring"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
}
