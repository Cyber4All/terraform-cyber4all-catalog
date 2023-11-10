output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = module.cluster.ecs_cluster_arn
}

output "ecs_cluster_asg_name" {
  description = "The name of the ECS cluster's Auto Scaling Group."
  value       = module.cluster.ecs_cluster_asg_name
}

output "ecs_cluster_capacity_provider_name" {
  description = "The name of the ECS cluster's capacity provider."
  value       = module.cluster.ecs_cluster_capacity_provider_name
}

output "ecs_cluster_launch_template_id" {
  description = "The ID of the ECS cluster's launch template."
  value       = module.cluster.ecs_cluster_launch_template_id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.cluster.ecs_cluster_name
}

output "ecs_cluster_vpc_subnet_ids" {
  description = "The IDs of the ECS cluster's VPC subnets."
  value       = module.cluster.ecs_cluster_vpc_subnet_ids
}

output "ecs_instance_iam_role_arn" {
  description = "The ARN of the IAM role applied to ECS instances."
  value       = module.cluster.ecs_instance_iam_role_arn
}

output "ecs_instance_iam_role_id" {
  description = "The ID of the IAM role applied to ECS instances."
  value       = module.cluster.ecs_instance_iam_role_id
}

output "ecs_instance_iam_role_name" {
  description = "The name of the IAM role applied to ECS instances."
  value       = module.cluster.ecs_instance_iam_role_name
}

output "ecs_instance_security_group_id" {
  description = "The ID of the security group applied to ECS instances."
  value       = module.cluster.ecs_instance_security_group_id
}
