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
      environment_variables = {
        "${var.secret_key}1" = "${var.secret_value}1",
        "${var.secret_key}2" = "${var.secret_value}2"
      }
    },
    {
      name = "testing/example/database${var.random_id}"
      environment_variables = {
        "${var.secret_key}3" = "${var.secret_value}3",
        "${var.secret_key}4" = "${var.secret_value}4"
      }
    }
  ]
}
