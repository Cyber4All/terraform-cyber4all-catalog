output "cluster_name" {
  type        = string
  description = "The name of ECS cluster"
  value       = module.ecs.cluster_name
}

output "cluster_id" {
  type        = string
  description = "the id of the ECS cluster"
  value       = module.ecs.cluster_name
}
