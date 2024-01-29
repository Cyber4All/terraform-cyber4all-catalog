# ------------------------------------------------------------------------------
# DEPLOY AN AWS VPC
#
# This example shows how to deploy a single VPC in a given region. This example
# will create public and private subnets in each availability zone in the region.
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-cyber4all-sandbox"
    key    = "examples/dependencies/deploy-vpc-only/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-cyber4all-sandbox"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../../modules/vpc"

  vpc_name = "vpc-test${var.random_id}"
}
