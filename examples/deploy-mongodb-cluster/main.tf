terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.12.1"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.public_key
  private_key = var.private_key
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "test-vpc"

  num_availability_zones = 3

  create_private_subnets = false
}

module "mongodb" {
  source = "../../modules/mongodb"

  project_name = "CARD-Development"
  cluster_name = "test-cluster"

  cluster_authorized_iam_users = {
    "cwagne17-cli"             = "admin"
    "test-user-wo-permissions" = "read"
  }

  cluster_authorized_iam_roles = {
    "ecsTaskExecutionRole" = "read"
  }

  cluster_peering_cidr_block      = module.vpc.vpc_cidr_block
  cluster_peering_route_table_ids = [module.vpc.public_subnet_route_table_id]

  # Disabled for testing purposes
  enable_cluster_terimination_protection = false

}
