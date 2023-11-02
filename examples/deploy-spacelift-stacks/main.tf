# ------------------------------------------------------------------------------
# DEPLOY SPACELIFT STACKS
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
      version = "~> 1.6.0"
    }
  }
}

provider "aws" {
  region = var.region
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
  vpc_stack_name         = "test-vpc-stack-${var.random_id}"
  ecs_cluster_stack_name = "test-ecs-cluster-stack-${var.random_id}"

  repository = "terraform-cyber4all-catalog"
  branch     = "feature/sc-26579/develop-spacelift-stack-terraform-module"

  labels = ["folder: Environment/Testing", "project: terraform-cyber4all-catalog"]
}

module "vpc-stack" {
  source = "../../modules/spacelift-stack"

  stack_name = local.vpc_stack_name

  repository = local.repository
  branch     = local.branch
  path       = "examples/dependencies/deploy-vpc-only"

  # We want to be able to apply/delete in tests without having errors
  # in most cases, you will want to keep the default of `true`
  enable_protect_from_deletion = false
  enable_state_management      = true

  environment_variables = {
    "region"    = var.region,
    "random_id" = var.random_id,
  }

  labels = local.labels
}

# ------------------------------------------------------------------------------
# DEPLOY A STACK THAT IS DEPENDENT ON ANOTHER STACK (VPC -> ECS CLUSTER)
# ------------------------------------------------------------------------------

module "ecs-cluster-stack" {
  source = "../../modules/spacelift-stack"

  stack_name = local.ecs_cluster_stack_name

  repository = local.repository
  branch     = local.branch
  path       = "examples/dependencies/deploy-ecs-cluster-only"

  # We want to be able to apply/delete in tests without having errors
  # in most cases, you will want to keep the default of `true`
  enable_protect_from_deletion = false
  enable_state_management      = true

  environment_variables = {
    "region"    = var.region,
    "random_id" = var.random_id,
  }

  stack_dependencies = {
    (local.vpc_stack_name) = {
      "vpc_id"         = "vpc_id",
      "vpc_subnet_ids" = "private_subnet_ids",
    },
  }

  labels = local.labels
}
