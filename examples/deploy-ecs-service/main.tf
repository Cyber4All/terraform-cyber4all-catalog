# ------------------------------------------------------------------------------
# DEPLOY ECS SERVICES TO TEST EXTERNAL/INTERNAL CONNECTIVITY
#
# This example shows how to deploy an two ECS services to test external and
# internal connectivity. Both services are deployed to the same ECS cluster 
# and use the same container image. The only difference is that the external
# is attached to an Application Load Balancer and the internal service is
# not.
# 
# Unique Test Cases Covered:
# - Assert ALB health checks
# - Assert external connectivity
# - Assert auto-scaling behavior
# - Assert service connect (internal connectivity)
# - Assert secrets manager integration
# - Assert container logs
# ------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# -------------------------------------------
# AWS PROVIDER CONFIGURATION
# -------------------------------------------

provider "aws" {
  region = var.region
}


# -------------------------------------------
# CONVENIENCE VARIABLES
# -------------------------------------------

locals {
  name = "service-test${var.random_id}"
}


# -------------------------------------------
# CREATE VPC TO DEPLOY ECS CLUSTER AND SERVICES
# -------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  vpc_name               = local.name
  num_availability_zones = 3
}


# -------------------------------------------
# CREATE HTTP ALB TO ATTACH EXTERNAL ECS SERVICE
# -------------------------------------------

module "alb" {
  source = "../../modules/alb"

  alb_name = local.name

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.public_subnet_ids

  enable_https_listener = false
}


# -------------------------------------------
# CREATE ECS CLUSTER
# -------------------------------------------

module "cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = local.name

  cluster_instance_ami = var.cluster_instance_ami

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.private_subnet_ids
}


# -------------------------------------------
# SECRET MANAGER SECRET
# -------------------------------------------

module "secrets-manager" {
  source = "../../modules/secrets-manager"

  secrets = [
    {
      name = "testing/example/${local.name}"
      environment_variables = {
        "SECRET" = "SUPER_SECRET_VALUE"
      }
    }
  ]
}


# -------------------------------------------
# DEPLOY EXTERNAL/INTERNAL ECS SERVICES
# -------------------------------------------

module "external-ecs-service" {
  source = "../../modules/ecs-service"

  ecs_cluster_name = module.cluster.ecs_cluster_name
  ecs_service_name = "${local.name}-external"

  ecs_container_image = var.external_container_image
  ecs_container_port  = 8080

  ecs_container_environment_variables = {
    "MOCK_TYPE" = "rest-api"
  }

  ecs_container_secrets = {
    "SECRET" : module.secrets-manager.secret_arns[0]
  }
}
