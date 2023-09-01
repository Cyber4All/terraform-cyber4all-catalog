# -------------------------------------------------------------------------------------
# MANAGE SECRETS IN SECRETS MANAGER
# 
# This module will create a secret and initialize the secret keys with an empty string.
# Keys that have already been initialized in a secret will not overwrite the existing
# value. The module includes the following:
# - Secrets Manager Secret
# - Secrets Manager Secret Version
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# -------------------------------------------
# CREATE THE SECRETS MANAGER SECRETS
# -------------------------------------------

resource "aws_secretsmanager_secret" "secret" {
  count = length(var.secrets)

  name        = var.secrets[count.index].name
  description = var.secrets[count.index].description

  recovery_window_in_days = 0
}


# -------------------------------------------
# GET THE CURRENT SECRET VERSIONS
# -------------------------------------------

data "aws_secretsmanager_secret_version" "secret" {
  count = length(var.secrets)

  secret_id = aws_secretsmanager_secret.secret[count.index].id
}


# -------------------------------------------
# INITIALIZE NEW SECRET VERSION
# -------------------------------------------

resource "aws_secretsmanager_secret_version" "secret" {
  count = length(var.secrets)

  secret_id = aws_secretsmanager_secret.secret[count.index].id

  secret_string = jsonencode(
    merge(
      # Initialize all the keys to an empty string
      { for key in var.secrets[count.index].keys : key => "" },

      # Overwrite the keys with existing values. However, if the
      # if a key is removed then the key -> value pair should also
      # be removed even when a value is present. 
      {
        for k, v in jsondecode(data.aws_secretsmanager_secret_version.secret[count.index].secret_string) :
        k => v
        if contains(
          keys(jsondecode(data.aws_secretsmanager_secret_version.secret[count.index].secret_string)),
          var.secrets[count.index].keys
        )
      }
    )
  )

  depends_on = [
    # We want to ensure that all CURRENT versions are retrieved prior
    # to performing logic.
    data.aws_secretsmanager_secret_version.secret
  ]
}
