# TODO add more outputs

output "secret_arn_references" {
  # append key to the end of the secret ARN
  value = flatten([
    for i in range(length(var.secrets)) :
    [
      for key in var.secrets[i].keys :
      "${aws_secretsmanager_secret_version.secret[i].arn}:${key}::"
    ]
  ])
}

output "decoded_string" {
  value = jsondecode(data.aws_secretsmanager_secret_version.secret[0].secret_string)
}
