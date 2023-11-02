output "dependency_mappings" {
  value = local.dependency_mappings
}

output "number_of_dependencies" {
  value = local.number_of_dependencies
}

output "number_of_output_references" {
  value = local.number_of_references
}

output "stack_id" {
  value = spacelift_stack.this.id
}

output "stack_iam_role_id" {
  value = length(aws_iam_role.this) == 1 ? aws_iam_role.this[0].id : null
}

output "stack_iam_role_arn" {
  value = length(aws_iam_role.this) == 1 ? aws_iam_role.this[0].arn : null
}

output "stack_iam_role_policy_arns" {
  value = aws_iam_role_policy_attachment.this[*].policy_arn
}
