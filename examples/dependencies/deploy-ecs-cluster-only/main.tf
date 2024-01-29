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

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    hostname     = "spacelift.io"
    organization = "cyber4all"

    workspaces = {
      # This is defined in ../deploy-spacelift-stacks/main.tf
      name = "test-vpc-${var.region}${var.random_id}"
    }
  }
}

module "cluster" {
  source = "../../../modules/ecs-cluster"

  cluster_name = "cluster-test${var.random_id}"

  cluster_instance_ami = var.cluster_instance_ami

  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  cluster_max_size = 2
}
