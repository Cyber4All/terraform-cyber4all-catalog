output "ecs_cluster_stack_id" {
  value = module.ecs-cluster-stack.stack_id
}

output "ecs_cluster_stack_iam_role_id" {
  value = module.ecs-cluster-stack.stack_iam_role_id
}

output "ecs_cluster_stack_iam_role_arn" {
  value = module.ecs-cluster-stack.stack_iam_role_arn
}

output "ecs_cluster_stack_iam_role_policy_arns" {
  value = module.ecs-cluster-stack.stack_iam_role_policy_arns
}

output "vpc_stack_id" {
  value = module.vpc-stack.stack_id
}

output "vpc_stack_iam_role_id" {
  value = module.vpc-stack.stack_iam_role_id
}

output "vpc_stack_iam_role_arn" {
  value = module.vpc-stack.stack_iam_role_arn
}

output "vpc_stack_iam_role_policy_arns" {
  value = module.vpc-stack.stack_iam_role_policy_arns
}

output "dependency_mappings" {
  value = module.ecs-cluster-stack.dependency_mappings
}

output "number_of_dependencies" {
  value = module.ecs-cluster-stack.number_of_dependencies
}

output "number_of_output_references" {
  value = module.ecs-cluster-stack.number_of_output_references
}
