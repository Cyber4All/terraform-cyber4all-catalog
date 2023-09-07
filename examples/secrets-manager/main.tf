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
          name  = "${var.secret_key}1",
          value = "${var.secret_value}1"
        },
        {
          name  = "${var.secret_key}2",
          value = "${var.secret_value}2"
        }
      ]
    },
    {
      name = "testing/example/database${var.random_id}"
      environment = [
        {
          name  = "${var.secret_key}3",
          value = "${var.secret_value}3"
        },
        {
          name  = "${var.secret_key}4",
          value = "${var.secret_value}4"
        }
      ]
    }
  ]
}
