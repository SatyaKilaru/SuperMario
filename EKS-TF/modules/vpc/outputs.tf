output "vpc_id" {
  description = "Resolved VPC ID."
  value       = local.vpc_id
}

output "subnet_ids" {
  description = "Resolved list of subnet IDs."
  value       = local.subnet_ids
}
