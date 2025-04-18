# -------------------------------------------------------------------------------------
# ELASTIC CONTAINER SERVICE (ECS) CLUSTER
# 
# This module will create an ECS Cluster that supports Fargate as the available
# capacity providers. The module uses the Fargate provider as the default 
# strategy for cluster auto scaling (CAS)
#
# Service mesh connectivity will be managed with ECS Service Connect. The default
# namespace for the cluster will also be the cluster name.
#
# The module includes the following:
#
# - ECS Cluster
# - ECS Cluster's CloudWatch Log Group
# - ECS Cluster's CloudMap Namespace
# - ECS Cluster's Capacity Provider Strategy
#
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE ECS CLUSTER

# AND ASSOCIATED RESOURCES (LOG GROUP, NAMESPACE).

# ------------------------------------------------------------


# -------------------------------------------
# CREATE CLUSTER
# -------------------------------------------

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.cluster.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  service_connect_defaults {
    # For any service that is deployed to this cluster, it'll automatically
    # use this namespace for Service Connect when unspecified.
    namespace = aws_service_discovery_http_namespace.cluster.arn
  }

  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_service_discovery_http_namespace.cluster
  ]
}


# -------------------------------------------
# CREATE LOG GROUP FOR CLUSTER
# -------------------------------------------

# tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "cluster" {
  name = "/aws/ecs/${var.cluster_name}-logs"

  retention_in_days = 90
}


# -------------------------------------------
# CREATE NAMESPACE FOR SERVICE CONNECT 
# -------------------------------------------

resource "aws_service_discovery_http_namespace" "cluster" {
  name        = var.cluster_name
  description = "Terraform managed namespace to enabled ECS Service Connect for ${var.cluster_name}"
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE CAPACITY 

# PROVIDER STRATEGY FOR THE CLUSTER.

# ------------------------------------------------------------


# -------------------------------------------
# ASSIGN CLUSTER CAPACITY PROVIDER STRATEGY
# -------------------------------------------

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    "FARGATE",
  ]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"

    # The number of tasks, at a minimum,
    # to run on the specified capacity provider.
    base = 1

    # The relative percentage of the total number of 
    # launched tasks that should use the specified
    # capacity provider. This value only goes into
    # affect after the base number of tasks is met.
    weight = 100
  }

}

# ----------------------------------------------
# CREATE DEFAULT SECURITY GROUP FOR ECS SERVICES
# ----------------------------------------------

resource "aws_security_group" "default" {
  name        = "${var.cluster_name}-ecs-services-sg"
  description = "Terraform managed security group for ${var.cluster_name} ECS services."

  vpc_id = var.vpc_id
}

# TODO: @Diego This is a default security group. Since we will be using awsvpc
# networking mode, we should be able to restrict the traffic according
# to the host port mapping in the ECS service definition. This will
# looked at later in Diego's Epic over the summer.
resource "aws_vpc_security_group_ingress_rule" "service" {
  security_group_id = aws_security_group.default.id
  description       = "All all inbound tcp traffic."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "service" {
  security_group_id = aws_security_group.default.id
  description       = "Allow all outbound tcp traffic."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535
}
