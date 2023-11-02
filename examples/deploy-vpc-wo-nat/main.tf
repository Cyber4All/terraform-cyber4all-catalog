# ------------------------------------------------------------------------------
# DEPLOY AN AWS VPC WITHOUT A NAT GATEWAY
#
# This example shows how to deploy a single VPC in a given region without configuring
# a NAT gateway. This example will create public and private-persist subnets in 
# each availability zone in the region.
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

  vpc_name = "vpc-wo-nat-${var.random_id}"

  create_nat_gateway = false
}
