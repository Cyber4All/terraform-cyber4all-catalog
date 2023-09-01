output "secret_arn_references" {
  value = module.secrets-manager.secret_arn_references
}

output "decoded_string" {
  value     = module.secrets-manager.decoded_string
  sensitive = true
}
