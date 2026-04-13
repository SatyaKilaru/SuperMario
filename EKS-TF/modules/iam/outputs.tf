output "cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."
  value       = aws_iam_role.cluster.arn
}

output "cluster_role_name" {
  description = "Name of the IAM role used by the EKS control plane."
  value       = aws_iam_role.cluster.name
}

output "node_role_arn" {
  description = "ARN of the IAM role used by EKS worker nodes."
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Name of the IAM role used by EKS worker nodes."
  value       = aws_iam_role.node.name
}

output "node_policy_attachments" {
  description = "List of policy attachments on the node role (for depends_on wiring)."
  value = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy.id,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy.id,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly.id,
  ]
}

output "cluster_policy_attachment" {
  description = "ID of the cluster policy attachment (for depends_on wiring)."
  value       = aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy.id
}
