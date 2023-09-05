output "secret_arn_references" {
  description = "List of ARNs with appended references that can be used in other services such as ECS."
  # append key to the end of the secret ARN
  value = flatten([
    for i in range(length(var.secrets)) :
    [
      for key in var.secrets[i].keys :
      "${aws_secretsmanager_secret_version.secret[i].arn}:${key}::"
    ]
  ])
}
