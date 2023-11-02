output "stack_id" {
  value = module.stack.stack_id
}

output "stack_iam_role_id" {
  value = module.stack.stack_iam_role_id
}

output "stack_iam_role_arn" {
  value = module.stack.stack_iam_role_arn
}

output "stack_iam_role_policy_arns" {
  value = module.stack.stack_iam_role_policy_arns
}

output "dependency_mappings" {
  value = module.ecs-cluster-stack.dependency_mappings
}

output "number_of_dependencies" {
  value = module.ecs-cluster-stack.number_of_dependencies
}

output "number_of_references" {
  value = module.ecs-cluster-stack.number_of_references
}

output "stack_dependencies" {
  value = module.ecs-cluster-stack.stack_dependencies
}
