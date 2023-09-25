output "secret_arns" {
  value = module.secrets-manager.secret_arns
}

output "secret_arn_references" {
  value = module.secrets-manager.secret_arn_references
}

output "secret_names" {
  value = module.secrets-manager.secret_names
}
