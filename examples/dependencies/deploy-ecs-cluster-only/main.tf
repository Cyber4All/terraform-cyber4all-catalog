# ------------------------------------------------------------------------------
# DEPLOY AN AWS ECS CLUSTER
#
# This example shows how to deploy a single ECS cluster in a given region. This
# example does not create a VPC... it assumes that you have already deployed and
# variables for the VPC are passed in.
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

module "cluster" {
  source = "modules/ecs-cluster"

  cluster_name = "cluster${var.random_id}"

  cluster_instance_ami = var.cluster_instance_ami

  vpc_id         = var.vpc_id
  vpc_subnet_ids = var.vpc_subnet_ids

  cluster_max_size = 2
}
