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
      name = "just/chuck/testa"
      keys = [
        "JOSUE_IS_CUTE",
        "MIKE_IS_COOL",
        "CHRIS_YEP"
      ]
    }
  ]
}
