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

module "ecs-service" {
  source = "../../modules/ecs-service"

  ecs_cluster_name = module.cluster.cluster_name
  ecs_service_name = local.name

  create_scheduled_task = true
  enable_container_logs = true

  environment_variables = {
    "NODE_ENV" = "test"
  }

  # TODO create an image for testing
  image          = ""
  override_image = true

  # TODO define this, and create script to test with
  scheduled_task_event_pattern = {

  }
  scheduled_task_subnet_ids = module.vpc.public_subnet_ids

}

