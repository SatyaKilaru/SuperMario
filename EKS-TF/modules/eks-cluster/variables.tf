variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role the cluster control plane assumes."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs in which to place the cluster ENIs."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g. '1.29'). Leave null for AWS default."
  type        = string
  default     = null
}

variable "endpoint_public_access" {
  description = "Whether the EKS public API endpoint is enabled."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the EKS private API endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_policy_attachment" {
  description = "Dependency handle for the AmazonEKSClusterPolicy attachment."
  type        = any
  default     = null
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}
