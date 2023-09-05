terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"

  secrets = [
    {
      name = "testing/example/service${var.random_id}"
      environment = [
        {
          name  = "NODE_ENV",
          value = "prod"
        },
        {
          name  = "SOME_SECRET",
          value = "stuff",
        }
      ]
    },
    {
      name = "testing/example/database${var.random_id}"
      environment = [
        {
          name  = "DB_USERNAME",
          value = "admin"
        },
        {
          name  = "DB_PASSWORD",
          value = "password123",
        }
      ]
    }
  ]
}
