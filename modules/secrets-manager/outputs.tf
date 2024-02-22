output "secret_arns" {
  description = "List of ARNs for the secrets managed by the module."
  value       = aws_secretsmanager_secret.secret[*].arn
}

output "secret_arn_references" {
  description = "List of ARNs with appended references that can be used in other services such as ECS."
  # append key to the end of the secret ARN
  value = flatten([
    for i in range(length(var.secrets)) :
    [
      for k, v in var.secrets[i].environment_variables :
      "${aws_secretsmanager_secret_version.secret[i].arn}:${k}::"
    ]
  ])
}

output "secret_names" {
  description = "List of secret names for the secrets managed by the module."
  value       = aws_secretsmanager_secret.secret[*].name
}
