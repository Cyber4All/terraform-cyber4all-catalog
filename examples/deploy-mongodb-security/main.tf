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

provider "aws" {
  region = "us-east-1"
}

provider "mongodbatlas" {
  assume_role {
    role_arn = var.mongodb_role_arn
  }
  secret_name = "mongodb/project/sandbox"
  region      = "us-east-1"
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
