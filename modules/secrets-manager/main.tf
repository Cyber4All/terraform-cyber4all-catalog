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
# CREATE A CUSTOMER MANAGED KEY TO ENCRYPT W/
# -------------------------------------------

resource "aws_kms_key" "secret" {
  description         = "CMK for Secrets Manager Encryption"
  enable_key_rotation = true

}


# -------------------------------------------
# CREATE THE SECRETS MANAGER SECRETS
# -------------------------------------------

resource "aws_secretsmanager_secret" "secret" {
  count = length(var.secrets)

  name        = var.secrets[count.index].name
  description = var.secrets[count.index].description

  kms_key_id = aws_kms_key.secret.arn

  recovery_window_in_days = 0

}


# -------------------------------------------
# CREATE NEW SECRET VERSION
# -------------------------------------------

resource "aws_secretsmanager_secret_version" "secret" {
  count = length(var.secrets)

  secret_id = aws_secretsmanager_secret.secret[count.index].id

  secret_string = jsonencode(
    {
      # Converts the objects into a single map
      for s in var.secrets[count.index].environment :
      s["name"] => sensitive(s["value"])
    }
  )

}
