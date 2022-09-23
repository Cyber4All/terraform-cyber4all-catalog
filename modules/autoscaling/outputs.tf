
output "autoscaling_group_id" {
  description = "the id of the generated autoscaling group"
  value       = module.autoscaling.autoscaling_group_id
}

output "autoscaling_group_arn" {
  description = "the arn of the generated autoscaling group"
  value       = module.autoscaling.autoscaling_group_arn
}
