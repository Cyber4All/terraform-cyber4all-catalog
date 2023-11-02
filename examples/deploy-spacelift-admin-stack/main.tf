# ------------------------------------------------------------------------------
# DEPLOY AN ADMIN SPACELIFT STACK WITHOUT AN AWS INTEGRATION
#
# This example shows how to deploy an admin spacelift stack without an AWS
# integration. This is useful if you want to use the stack to deploy other space-
# lift stacks and resources, but don't want to deploy any AWS resources with the
# stack itself.
# ------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.1.9"
    }
  }
}


# --------------------------------------------------
# CONFIGURE OUR SPACELIFT CONNECTION
# --------------------------------------------------

# Retrieves the spacelift api key from AWS Secrets Manager
# in the AWS account configured in the AWS provider
data "aws_secretsmanager_secret" "spacelift" {
  name = "spacelift/sandbox"
}

data "aws_secretsmanager_secret_version" "spacelift" {
  secret_id = data.aws_secretsmanager_secret.spacelift.id
}

provider "spacelift" {
  api_key_endpoint = jsondecode(data.aws_secretsmanager_secret_version.spacelift.secret_string)["api_key_endpoint"]
  api_key_id       = jsondecode(data.aws_secretsmanager_secret_version.spacelift.secret_string)["api_key_id"]
  api_key_secret   = jsondecode(data.aws_secretsmanager_secret_version.spacelift.secret_string)["api_key_secret"]
}


# --------------------------------------------------
# DEPLOY THE STACK MODULE
# --------------------------------------------------

locals {
  stack_name = "test-admin-stack-${var.random_id}"
}

module "stack" {
  source = "../../modules/cicd-pipelines/spacelift-stack"

  stack_name = local.stack_name

  repository   = "terraform-cyber4all-catalog"
  branch       = "feature/sc-26579/develop-spacelift-stack-terraform-module" # TODO update this to main before merge
  project_root = "examples/deploy-spacelift-stack"

  create_iam_role = false

  enable_admin_stack      = true
  enable_state_management = true

  # We want to be able to apply/delete in tests without having errors
  # in most cases, you will want to keep the default of `true`
  protect_from_deletion = false
}
