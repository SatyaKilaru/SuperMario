resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
  }

  tags = var.tags

  # IAM permissions must be created before the cluster and destroyed after it,
  # otherwise EKS cannot clean up managed EC2 infrastructure such as SGs.
  depends_on = [var.cluster_policy_attachment]
}
