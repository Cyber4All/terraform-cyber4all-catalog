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
  name = "service-test${var.random_id}"
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
  vpc_subnet_ids = module.vpc.private_subnet_ids

  cluster_max_size = 1
}

module "ecs-service" {
  source = "../../modules/ecs-service"

  ecs_cluster_name = module.cluster.ecs_cluster_name

  ecs_service_name = local.name

  enable_container_logs       = true
  enable_service_auto_scaling = true

  # container_image               = "cyber4all/mock-container-image:latest"
  docker_credentials_secret_arn = "arn:aws:secretsmanager:us-east-1:353964526231:secret:dockerhub/cyber4all-HUtIy5"
  container_port                = 8080

  environment_variables = {
    "MOCK_TYPE" = "rest-api"
  }
}
