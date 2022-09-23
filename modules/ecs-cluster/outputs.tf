output "cluster_name" {
  description = "The name of ECS cluster"
  value       = module.ecs.cluster_name
}

output "cluster_id" {
  description = "the id of the ECS cluster"
  value       = module.ecs.cluster_name
}
