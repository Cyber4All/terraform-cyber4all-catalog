terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"

  secrets = [
    {
      name = "testing/example/service"
      keys = [
        "NODE_ENV",
        "SOME_SECRET",
      ]
    },
    {
      name = "testing/example/database"
      keys = [
        "DB_USERNAME",
        "DB_PASSWORD"
      ]
    }
  ]
}
