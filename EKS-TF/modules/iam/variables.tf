variable "name_prefix" {
  description = "Prefix applied to IAM role names (typically '<project>-<env>')."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all IAM resources."
  type        = map(string)
  default     = {}
}
