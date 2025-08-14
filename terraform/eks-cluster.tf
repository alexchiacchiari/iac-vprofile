module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # Add these explicit configurations
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  # Increase timeout for cluster creation
  # cluster_create_timeout and cluster_delete_timeout are not supported attributes for this module and have been removed.

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    
    # Add explicit IAM role creation
    create_iam_role = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    }
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Add explicit dependencies and wait conditions
      create_before_destroy = true
      force_update_version  = true
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      create_before_destroy = true
      force_update_version  = true
    }
  }
}

# Optional: Add an explicit dependency to ensure cluster is ready
resource "time_sleep" "wait_for_cluster" {
  depends_on = [module.eks]

  create_duration = "180s"
}
