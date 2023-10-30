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

module "vpc" {
  source = "../../modules/vpc"

  vpc_name               = "test-vpc-partial-azs-${var.random_id}}"
  num_availability_zones = 3
}
