
output "autoscaling_group_id" {
  type        = string
  description = "the id of the generated autoscaling group"
  value       = module.autoscaling.autoscaling_group_id
}

output "autoscaling_group_arn" {
  type        = string
  description = "the arn of the generated autoscaling group"
  value       = module.autoscaling.autoscaling_group_arn
}
