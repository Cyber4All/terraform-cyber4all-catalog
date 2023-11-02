output "dependency_mappings" {
  value = module.stack.dependency_mappings
}

output "number_of_dependencies" {
  value = module.stack.number_of_dependencies
}

output "number_of_output_references" {
  value = module.stack.number_of_output_references
}

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
  value = module.stack_iam_role_policy_arns
}
