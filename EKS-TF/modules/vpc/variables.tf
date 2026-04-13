variable "vpc_id" {
  description = "Explicit VPC ID to use. If null, the default VPC of the account is used."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Explicit list of subnet IDs for the EKS cluster. If empty, all subnets in the selected VPC are used."
  type        = list(string)
  default     = []
}

variable "use_default_vpc" {
  description = "When vpc_id is null, whether to select the account's default VPC."
  type        = bool
  default     = true
}
