output "vpc_stack_id" {
  value = module.vpc-stack.stack_id
}

output "ecs_cluster_stack_id" {
  value = module.ecs-cluster-stack.stack_id
}
