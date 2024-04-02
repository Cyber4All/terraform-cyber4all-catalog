# -------------------------------------------------------------------------------------
# ELASTIC CONTAINER SERVICE (ECS) CLUSTER
# 
# This module will create an ECS Cluster that supports both EC2 and Fargate as available
# capacity providers. The module uses an EC2 auto scaling group (ASG) as the default 
# strategy for cluster auto scaling (CAS)
#
# The module uses instance refresh for any updates to the ASG's launch template. This
# ensures that the cluster is always running the latest version of the ECS AMI.
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
# - ECS Cluster's Capacity Provider
# - ECS Cluster's Auto Scaling Group
# - (Optional) ECS Cluster's Auto Scaling Group SNS Notifications
# - ECS Cluster's Launch Template
# - ECS Cluster's Launch Template's Security Group
# - ECS Cluster's Launch Template's IAM Role/Instance Profile
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

# PROVIDER STRATEGY FOR THE CLUSTER. THIS PROVIDER USES THE

# AUTO SCALING GROUP TO MANAGE THE CLUSTER CAPACITY.

# ------------------------------------------------------------


# -------------------------------------------
# ATTACH CLUSTER CAPACITY PROVIDER STRATEGY
# -------------------------------------------

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    "FARGATE",
    aws_ecs_capacity_provider.cluster.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cluster.name

    # Since only one provider is being set, it'll place the 1st task
    # according to this provider. For all remaining tasks it'll place
    # in a 1:1 ratio to its self.
    #
    # If another provider strategy was added the weight would define
    # the ratio. For example, a FARGATE default capacity provider
    # with base = 0 (only one base can be defined) and a weight of 2
    # would imply that all remaining tasks after the first placed task
    # will split a 1:2 ratio between the EC2 provider and FARGATE provider
    base   = 1
    weight = 1
  }

}

# -------------------------------------------
# CREATE CLUSTER CAPACITY PROVIDER
# -------------------------------------------

resource "aws_ecs_capacity_provider" "cluster" {
  name = "${var.cluster_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.cluster.arn
    managed_termination_protection = var.autoscaling_termination_protection ? "ENABLED" : "DISABLED"

    managed_scaling {
      # The default warmup is 300s (5m). This value slows down scaling behaviors.
      # This value may need adjustment as expirementation occurs. Since no life-
      # cycles are defined, and no ELB association to the instance directly our
      # speed should be limited to the OS boot time of the AMI.
      instance_warmup_period = 30

      maximum_scaling_step_size = var.capacity_provider_max_scale_step
      minimum_scaling_step_size = var.capacity_provider_min_scale_step
      target_capacity           = var.capacity_provider_target

      status = "ENABLED"
    }
  }

  depends_on = [
    aws_ecs_cluster.cluster
  ]
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE AUTO SCALING 

# GROUP FOR THE ECS CLUSTER AND AN OPTIONAL SNS NOTIFICATION

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE LAUNCH TEMPLATE FOR THE ASG
# -------------------------------------------

resource "aws_autoscaling_group" "cluster" {
  name = "${var.cluster_name}-asg"

  max_size = var.cluster_max_size
  min_size = var.cluster_min_size

  vpc_zone_identifier = var.vpc_subnet_ids

  # The default cooldown of 60s is being used to denote that scale out/in requests
  # should wait 60 seconds between the next request. This is the same time interval
  # as ECS sending metrics to CloudWatch. This ideally, should sync the scaling
  # process with CloudWatch alarm responses.
  default_cooldown = 60

  # This value matches the instance_warmup_period defined by the ecs capacity
  # provider managed scaling configuration.
  default_instance_warmup = 30

  health_check_type = "EC2"

  protect_from_scale_in = var.autoscaling_termination_protection

  launch_template {
    id      = aws_launch_template.cluster.id
    version = aws_launch_template.cluster.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      # After a number of instances are replaced and a checkpoint is
      # reached, the value of checkpoint_delay in seconds will elapse
      # before the next replacement occurs.
      checkpoint_delay = 300

      # This forces that instance refresh will occur one instance at a
      # time. This is ideal for an ASG that manages a small number of
      # instances. Suppose 5 instances are being replaced with a 300s
      # delay and 30s warmup; the refresh would total 27.5m.
      min_healthy_percentage = 100

      # Since we are using a launch_template that maintains versions,
      # when an instance refresh fails it'll automatically rollback the
      # changes being made.
      auto_rollback = true
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  depends_on = [
    # The cluster must be created prior to the ASG.
    # The EC2 instances will not be able to register
    # to an ECS cluster that does not exist.
    aws_ecs_cluster.cluster
  ]

  timeouts {
    delete = "60m"
  }

  lifecycle {
    create_before_destroy = false
  }

}


# -------------------------------------------
# CREATE AUTO SCALING NOTIFICATIONS
# -------------------------------------------

resource "aws_autoscaling_notification" "cluster" {
  count = length(var.autoscaling_sns_topic_arns)

  group_names = [
    aws_autoscaling_group.cluster.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = var.autoscaling_sns_topic_arns[count.index]
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE LAUNCH TEMPLATE 

# FOR THE ASG AND ASSOCIATED RESOURCES.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE LAUNCH TEMPLATE FOR THE ASG
# -------------------------------------------

resource "aws_launch_template" "cluster" {
  update_default_version = true

  name        = "${var.cluster_name}-lt"
  description = "Terraform managed launch template for ${var.cluster_name}"

  image_id      = var.cluster_instance_ami
  instance_type = var.cluster_instance_type

  vpc_security_group_ids = [
    aws_security_group.default.id,
    aws_security_group.cluster.id
  ]

  user_data = base64encode(templatefile(
    "${path.module}/scripts/user_data.sh",
    { CLUSTER_NAME = var.cluster_name }
  ))

  iam_instance_profile {
    arn = aws_iam_instance_profile.cluster.arn
  }

  credit_specification {
    cpu_credits = "standard"
  }

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# -------------------------------------------
# CREATE DEFAULT SECURITY GROUP FOR ASG
# -------------------------------------------

resource "aws_security_group" "default" {
  name        = "${var.cluster_name}-ecs-agent"
  description = "Terraform managed security group for ${var.cluster_name} ECS agent."

  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "agent" {
  security_group_id = aws_security_group.default.id
  description       = "Opens a dynamic ephemeral port for tasks using the bridge network mode."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 32768
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "agent" {
  security_group_id = aws_security_group.default.id
  description       = "Allow all outbound tcp traffic."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535
}


# -------------------------------------------
# CREATE SECURITY GROUP FOR ASG
# -------------------------------------------

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-instance"
  description = "Terraform managed security group for ${var.cluster_name} ECS container instances."

  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "cluster" {
  count = length(var.cluster_ingress_access_ports)

  security_group_id = aws_security_group.cluster.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.cluster_ingress_access_ports[count.index]
  ip_protocol = "tcp"
  to_port     = var.cluster_ingress_access_ports[count.index]
}


# -------------------------------------------
# CREATE IAM ROLE/INSTANCE PROFILE
# -------------------------------------------

locals {
  cluster_iam_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
}

data "aws_iam_policy_document" "cluster" {
  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name_prefix = "${var.cluster_name}-cluster"

  description = "Terraform managed IAM role for ${var.cluster_name}"

  assume_role_policy    = data.aws_iam_policy_document.cluster.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "cluster" {
  count = length(local.cluster_iam_policies)

  policy_arn = local.cluster_iam_policies[count.index]
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_instance_profile" "cluster" {
  name = "${var.cluster_name}-ip"
  role = aws_iam_role.cluster.name
}
