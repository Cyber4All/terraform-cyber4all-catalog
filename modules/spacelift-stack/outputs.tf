output "dependency_mappings" {
  value       = local.dependency_mappings
  description = "A list of maps of stack dependency id to the variable mappings defined in the stack_dependencies variable"
}

output "number_of_dependencies" {
  value       = local.number_of_dependencies
  description = "The number of stack dependencies"
}

output "number_of_output_references" {
  value       = local.number_of_references
  description = "The number of variable mappings defined in the stack_dependencies variable"
}

output "stack_id" {
  value       = spacelift_stack.this.id
  description = "The id of the stack"
}
