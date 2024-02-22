# -------------------------------------------------------------------------------------
# MANAGE SECRETS IN SECRETS MANAGER
# 
# This module will create a secret and maintain the key/value pairs that are associated.
# The module includes the following:
# - Secrets Manager Secret
# - Secrets Manager Secret Version
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

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

# tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "secret" {
  count = length(var.secrets)

  name        = var.secrets[count.index].name
  description = var.secrets[count.index].description

  recovery_window_in_days = 0

}


# -------------------------------------------
# CREATE NEW SECRET VERSION
# -------------------------------------------

resource "aws_secretsmanager_secret_version" "secret" {
  count = length(var.secrets)

  secret_id = aws_secretsmanager_secret.secret[count.index].id

  secret_string = jsonencode(var.secrets[count.index].environment_variables)

}
