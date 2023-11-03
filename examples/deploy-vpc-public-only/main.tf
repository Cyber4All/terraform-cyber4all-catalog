# ------------------------------------------------------------------------------
# DEPLOY AN AWS VPC WITHOUT PRIVATE SUBNETS
#
# This example shows how to deploy a single VPC in a given region. This example
# will create public subnets in each availability zone in the region.
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

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "vpc-public-only${var.random_id}}"

  create_private_subnets = false
}
