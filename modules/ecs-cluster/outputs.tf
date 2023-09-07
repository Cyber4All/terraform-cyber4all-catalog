output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.cluster.arn
}

output "ecs_cluster_asg_name" {
  description = "The name of the ECS cluster's Auto Scaling Group."
  value       = aws_autoscaling_group.cluster.name
}

output "ecs_cluster_capacity_provider_name" {
  description = "The name of the ECS cluster's capacity provider."
  value       = aws_ecs_capacity_provider.cluster.name
}

output "ecs_cluster_launch_template_id" {
  description = "The ID of the ECS cluster's launch template."
  value       = aws_launch_template.cluster.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.cluster.name
}

output "ecs_cluster_vpc_subnet_ids" {
  description = "The IDs of the ECS cluster's VPC subnets."
  value       = aws_autoscaling_group.cluster.vpc_zone_identifier
}

output "ecs_instance_iam_role_arn" {
  description = "The ARN of the IAM role applied to ECS instances."
  value       = aws_iam_role.cluster.arn
}

output "ecs_instance_iam_role_id" {
  description = "The ID of the IAM role applied to ECS instances."
  value       = aws_iam_role.cluster.id
}

output "ecs_instance_iam_role_name" {
  description = "The name of the IAM role applied to ECS instances."
  value       = aws_iam_role.cluster.name
}

output "ecs_instance_security_group_id" {
  description = "The ID of the security group applied to ECS instances."
  value       = aws_security_group.cluster.id
}
