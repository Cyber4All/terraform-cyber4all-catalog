# -------------------------------------------------------------------------------------
# ELASTIC CONTAINER SERVICE (ECS)
# 
# This module will creates an ECS service that can be used for application deployments
# in an existing ECS cluster.
#
# The ECS service can support both FARGATE and EC2 compute. In addition to compute,
# the module supports running the task-definition as both a service or as a scheduled 
# task that can be triggered by an Event or rule.
#
# The module includes the following:
#
# - TODO: ADD THIS IN DEVELOPMENT
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

# THE FOLLOWING SECTION IS USED TO CONFIGURE THE SERVICE,

# AND ASSOCIATED RESOURCES (CloudWatch Alarms, IAM)

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE ECS SERVICE
# -------------------------------------------

# Condition: Network type should only support bridge mode
# Condition: Service Connect should be used, service registries is no longer used
# Condition: Alarms should be setup for rollback/deployment failures
# Condition: Capacity provider should be setup for default capacity provider when provided the launch_type should be ignored
# Condition: Load balancer should be conditionally setup 
# Condition: We should be using binpack for placement strategy
# Condition: Should only exist when create_scheduled_task is false

# resource "aws_ecs_service" "service" {}


# -------------------------------------------
# CREATE THE SERVICE ROLLBACK ALARM
# -------------------------------------------

# Condition: The alarm should be conditionally configured
# if the rollback alarm is enabled in the ecs-service resource

# resource "aws_cloudwatch_metric_alarm" "service" {}


# -------------------------------------------
# CREATE THE SERVICE ROLE
# -------------------------------------------

# Condition: This section may not actually be needed since
# we have service roles for the EC2 container instances

# data "iam_policy_document" "service" {}

# resource "aws_iam_role" "service" {}

# resource "aws_iam_role_policy_attachment" "service" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE THE SERVICE,

# AND ASSOCIATED RESOURCES (CloudWatch Alarms, IAM)

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE AUTOSCALING METRIC ALARMS
# -------------------------------------------

# Condition: All of the following resource should be created if
# enable_service_auto_scaling is true
# Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html
# Example: https://github.com/cn-terraform/terraform-aws-ecs-service-autoscaling/blob/main/main.tf

# resource "aws_cloudwatch_metric_alarm" "cpu_high" {}

# Condition: The low metric should be calculated based on the high
# if percentage is 90 for high then low should be 10

# resource "aws_cloudwatch_metric_alarm" "cpu_low" {}

# resource "aws_cloudwatch_metric_alarm" "mem_high" {}

# Condition: The high metric should be calculated based on the low
# if percentage is 90 for high then low should be 10

# resource "aws_cloudwatch_metric_alarm" "mem_low" {}


# -------------------------------------------
# CREATE THE AUTOSCALING METRIC ALARMS
# -------------------------------------------

# Condition: enable_service_auto_scaling is true
# Condition: Depends on aws_appautoscaling_target.target

# resource "aws_appautoscaling_policy" "scale_out" {}

# Condition: enable_service_auto_scaling is true
# Condition: Depends on aws_appautoscaling_target.target

# resource "aws_appautoscaling_policy" "scale_in" {}

# Condition: enable_service_auto_scaling is true

# resource "aws_appautoscaling_target" "target" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE THE ECS

# TASK-DEFINITION AND LOG GROUP

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE ECS TASK DEFINITION
# -------------------------------------------

# resource "aws_ecs_task_definition" "task" {}


# -------------------------------------------
# CREATE THE ECS TASK DEFINITION
# -------------------------------------------

# Condition: This container definition is the essential container
# Condition: It should always use bridge mode
# Condition: A change to the image in the container should be ignored

# data "aws_ecs_container_definition" "essential" {}


# -------------------------------------------
# CREATE THE ECS LOG GROUP FOR THE ESSENTIAL DEFINITION
# -------------------------------------------

# resource "aws" "cloudwatch_log_group" "task" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# SCHEDULED TASKS. WHEN A SCHEDULED TASK IS

# CONFIGURED, THE ECS SERVICE RESOURCE SHOULD

# NOT BE CREATED.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE ECS TARGET FOR THE RULE
# -------------------------------------------

# Condition: Should only exist when create_scheduled_task is true

# resource "aws_cloudwatch_event_target" "scheduled" {}


# -------------------------------------------
# CREATE THE RULE TO TRIGGER THE ECS TASK
# -------------------------------------------

# resource "aws_cloudwatch_event_rule" "custom" {}

# resource "aws_cloudwatch_event_rule" "cron" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# THE ALB ATTACHMENT FOR THE ECS SERVICE

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE LISTENER RULE TO ATTACH TO THE EXISTING LISTENER
# -------------------------------------------

# Condition: Should only exist is enable_alb_attachment is true
# Condition: Should depend_on the var.alb_listener

# resource "aws_lb_listener_rule" "alb" {}


# -------------------------------------------
# CREATE THE TARGET GROUP FOR THE RULE TO DIRECT TRAFFIC TO
# -------------------------------------------

# Condition: Should only exist is enable_alb_attachment is true

# resource "aws_lb_target_group" "alb" {}


