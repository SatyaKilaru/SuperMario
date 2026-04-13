variable "cluster_name" {
  description = "Name of the EKS cluster this node group attaches to."
  type        = string
}

variable "node_group_name" {
  description = "Name of the managed node group."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN that the node instances assume."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets in which to launch worker nodes."
  type        = list(string)
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Either ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"
}

variable "disk_size" {
  description = "Root EBS volume size (GiB) per node."
  type        = number
  default     = 20
}

variable "desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_policy_attachments" {
  description = "Dependency handle(s) for the worker-role policy attachments."
  type        = any
  default     = []
}

variable "tags" {
  description = "Tags applied to the node group."
  type        = map(string)
  default     = {}
}
