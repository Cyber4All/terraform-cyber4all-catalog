output "cluster_name" {
  description = "The name of ECS cluster"
  value       = module.ecs.cluster_name
}

output "cluster_id" {
  description = "the id of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "the arn of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "autoscaling_group_id" {
  description = "the id of the generated autoscaling group"
  value       = module.autoscaling.autoscaling_group_id
}

output "autoscaling_group_arn" {
  description = "the arn of the generated autoscaling group"
  value       = module.autoscaling.autoscaling_group_arn
}

output "security_group_id" {
  description = "the id of the security group created"
  value       = module.security_group.security_group_id
}

output "security_group_arn" {
  description = "the arn of the security group"
  value       = module.security_group.security_group_arn
}