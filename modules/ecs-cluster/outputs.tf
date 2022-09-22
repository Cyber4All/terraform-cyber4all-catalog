output "cluster_name" {
  type = string
  description = "The name of ECS cluster"
  value = module.ecs.cluster_name
}

output "cluster_id" {
  type = string
  description = "the id of the ECS cluster"
  value = module.ecs.cluster_name
}

output "autoscaling_group_id" {
  type = string
  description = "the id of the generated autoscaling group"
  value = module.autoscaling.autoscaling_group_id
}

output "autoscaling_group_arn" {
  type = string
  description = "the arn of the generated autoscaling group"
  value = module.autoscaling.autoscaling_group_arn
}

output "security_group_id" {
  type = string
  description = "the id of the security group generated"
  value = module.security_group.security_group_id
}

output "security_group_arn" {
  type = string
  description = "the arn of the security group generated"
  value = module.security_group.security_group_id
}