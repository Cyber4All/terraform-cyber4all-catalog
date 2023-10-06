terraform {
  required_providers {
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

  enable_cluster_auto_scaling           = true
  enable_cluster_automated_patches      = true
  enable_cluster_backups                = true
  enable_retain_deleted_cluster_backups = true

  cluster_authorized_iam_users = {
    "cwagne17-cli"             = "admin"
    "test-user-wo-permissions" = "read"
  }

  cluster_authorized_iam_roles = {
    "ecsTaskExecutionRole" = "read"
  }

  cluster_peering_subnets = module.vpc.public_subnet_ids

  # Disabled for testing purposes
  enable_cluster_terimination_protection = false

}
