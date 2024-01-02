# ------------------------------------------------------------------------------
# DEPLOY AN ECS SCHEDULED TASK
#
# This example shows how to deploy an ECS scheduled task that is triggered by a
# cron expression.
# 
# Unique Test Cases Covered:
# - Assert tasks are being placed
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
  name = "scheduled-test${var.random_id}"
}


# -------------------------------------------
# CREATE VPC TO DEPLOY ECS CLUSTER AND SERVICES
# -------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = local.name

  create_private_subnets = false
}


# -------------------------------------------
# CREATE ECS CLUSTER
# -------------------------------------------

module "cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = local.name

  cluster_instance_ami = var.cluster_instance_ami

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.public_subnet_ids

  cluster_max_size = 1
}


# -------------------------------------------
# DEPLOY ECS SCHEDULED TASKS
# -------------------------------------------

module "ecs-scheduled-task-expression" {
  source = "../../modules/ecs-service"

  ecs_cluster_name = module.cluster.ecs_cluster_name
  ecs_service_name = "${local.name}-expression"

  ecs_container_image = var.container_image
  ecs_container_environment_variables = {
    "MOCK_TYPE" = "single-process"
  }

  create_scheduled_task          = true
  scheduled_task_cron_expression = "rate(2 minutes)"
  scheduled_task_subnet_ids      = module.vpc.public_subnet_ids
}

module "ecs-scheduled-task-cron" {
  source = "../../modules/ecs-service"

  ecs_cluster_name = module.cluster.ecs_cluster_name
  ecs_service_name = "${local.name}-cron"

  ecs_container_image = var.container_image
  ecs_container_environment_variables = {
    "MOCK_TYPE" = "single-process"
  }

  create_scheduled_task          = true
  scheduled_task_cron_expression = "cron(0/2 * * * ? *)"
  scheduled_task_subnet_ids      = module.vpc.public_subnet_ids
}
