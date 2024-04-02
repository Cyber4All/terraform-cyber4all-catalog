terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.12.1"
    }
  }
}

provider "mongodbatlas" {
  # assume_role {
  #   role_arn = var.mongodb_role_arn
  # }
  # secret_name = "mongodb/project/sandbox"
  # region      = "us-east-1"
  public_key  = "tkdjexks"
  private_key = "0433abce-8135-449c-8848-66fd51122b92"
}

module "mongodb-security" {
  source = "../../modules/mongodb-security"

  project_name = "Sandbox"

  authorized_iam_users = {
    "cwagne17-cli"             = "admin@database"
    "test-user-wo-permissions" = "read"
  }

  authorized_iam_roles = {
    "ecsTaskExecutionRole" = "read"
  }
}