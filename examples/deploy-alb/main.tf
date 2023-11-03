# ------------------------------------------------------------------------------
# DEPLOY APPLICATION LOAD BALANCER (WITH HTTPS)
#
# This example shows how to deploy an AWS ALB with an HTTPS listener. This example
# creates a VPC to deploy the ALB into.
# ------------------------------------------------------------------------------

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

# --------------------------------------------------------------------
# CREATE THE VPC
# --------------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "vpc${var.random_id}"
  cidr = "10.0.0.0/16"

  azs            = [for letter in ["a", "b", "c"] : "${var.region}${letter}"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}


# --------------------------------------------------------------------
# CREATE THE ALB
# --------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  alb_name = "alb${var.random_id}"

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.public_subnets

  enable_https_listener = true

  hosted_zone_name = "lieutenant-dan.click"
}
