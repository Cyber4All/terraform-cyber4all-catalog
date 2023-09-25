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

locals {
  name = "ecs-event-task${var.random_id}"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name               = local.name
  num_availability_zones = 3
}

module "cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = local.name

  cluster_instance_ami = var.cluster_instance_ami

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.private_subnets_ids

  cluster_max_size = 1
}

# module "ecs-service" {

# }

