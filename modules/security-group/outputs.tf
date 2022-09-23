output "security_group_id" {
  type        = string
  description = "the id of the security group created"
  value       = module.security_group.security_group_id
}

output "security_group_arn" {
  type        = string
  description = "the arn of the security group"
  value       = module.security_group.security_group_arn
}