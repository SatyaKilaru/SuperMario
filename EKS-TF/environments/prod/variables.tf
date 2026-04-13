variable "project" {
  description = "Project name, used to prefix resources."
  type        = string
  default     = "supermario"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)."
  type        = string
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
}

# --- Networking ---
variable "vpc_id" {
  description = "VPC ID. When null, the default VPC is used."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for the cluster. When empty, all subnets in the selected VPC are used."
  type        = list(string)
  default     = []
}

variable "use_default_vpc" {
  description = "Whether to use the default VPC when vpc_id is null."
  type        = bool
  default     = true
}

# --- EKS cluster ---
variable "kubernetes_version" {
  description = "Kubernetes version of the cluster."
  type        = string
  default     = null
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "endpoint_private_access" {
  type    = bool
  default = false
}

# --- Node group ---
variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "tags" {
  description = "Extra tags merged into the common tag set."
  type        = map(string)
  default     = {}
}
