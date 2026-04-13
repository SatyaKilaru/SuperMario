locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

module "iam" {
  source      = "../../modules/iam"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "vpc" {
  source          = "../../modules/vpc"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  use_default_vpc = var.use_default_vpc
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  cluster_name              = "${local.name_prefix}-eks"
  cluster_role_arn          = module.iam.cluster_role_arn
  subnet_ids                = module.vpc.subnet_ids
  kubernetes_version        = var.kubernetes_version
  endpoint_public_access    = var.endpoint_public_access
  endpoint_private_access   = var.endpoint_private_access
  cluster_policy_attachment = module.iam.cluster_policy_attachment
  tags                      = local.common_tags
}

module "eks_node_group" {
  source = "../../modules/eks-node-group"

  cluster_name            = module.eks_cluster.cluster_name
  node_group_name         = "${local.name_prefix}-ng"
  node_role_arn           = module.iam.node_role_arn
  subnet_ids              = module.vpc.subnet_ids
  instance_types          = var.instance_types
  capacity_type           = var.capacity_type
  disk_size               = var.disk_size
  desired_size            = var.desired_size
  min_size                = var.min_size
  max_size                = var.max_size
  node_policy_attachments = module.iam.node_policy_attachments
  tags                    = local.common_tags
}
