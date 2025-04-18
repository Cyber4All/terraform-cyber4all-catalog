output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.cluster.arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.cluster.name
}

output "ecs_default_security_group_id" {
  description = "The default security group id."
  value       = aws_security_group.default.id
}
