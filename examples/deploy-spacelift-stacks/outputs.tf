output "vpc_stack_id" {
  value = module.vpc-stack.stack_id
}

output "ecs_cluster_stack_id" {
  value = module.ecs-cluster-stack.stack_id
}

output "ecs_cluster_dependency_mappings" {
  value = module.ecs-cluster-stack.dependency_mappings
}

output "ecs_cluster_number_of_dependencies" {
  value = module.ecs-cluster-stack.number_of_dependencies
}

output "ecs_cluster_number_of_output_references" {
  value = module.ecs-cluster-stack.number_of_output_references
}
