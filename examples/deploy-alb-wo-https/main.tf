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
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "alb-test${var.random_id}"
  cidr = "10.0.0.0/16"

  azs            = [for letter in ["a", "b", "c"] : "${var.region}${letter}"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "alb" {
  source = "../../modules/alb"

  alb_name = "alb-test${var.random_id}"

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.public_subnets

  enable_https_listener = false

}
