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
# RETRIEVE THE AWS MANAGED SERVICE ROLE
# -------------------------------------------

data "aws_iam_role" "service" {
  count = var.enable_load_balancer && !var.create_scheduled_task ? 1 : 0

  name = "AWSServiceRoleForECS"
}


# -------------------------------------------
# RETRIEVE THE ECS CLUSTER
# -------------------------------------------

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster_name

  lifecycle {
    # If the ECS cluster is not in an ACTIVE state, then the ECS service cannot 
    # be created and the module should fail.
    postcondition {
      condition     = self.status == "ACTIVE"
      error_message = "The ECS cluster must be in an ACTIVE state before creating the ECS service. Currently the ECS cluster is ${self.status}."
    }

    # If the ECS service is using Service Connect, a default namespace must be
    # configured for the ECS cluster.
    postcondition {
      condition     = !var.enable_service_connect || self.service_connect_defaults[0].namespace != null
      error_message = "An ECS service using Service Connect must have a default namespace configured for the ECS cluster."
    }
  }
}


# -------------------------------------------
# CREATE THE ECS SERVICE
# -------------------------------------------

# Condition: Network type should only support bridge mode

resource "aws_ecs_service" "service" {
  count = !var.create_scheduled_task ? 1 : 0

  cluster = data.aws_ecs_cluster.cluster.arn

  name            = var.ecs_service_name
  task_definition = local.task_definition

  iam_role = var.enable_load_balancer ? data.aws_iam_role.service[0].arn : null

  deployment_circuit_breaker {
    enable   = var.enable_deployment_rollback
    rollback = true
  }

  # The upper and lower limits (as a percentage of the service's desiredCount)
  # of the unmber of running tasks that should be maintained in the service
  # during a deployment.
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 66
  desired_count                      = var.desired_number_of_tasks

  enable_ecs_managed_tags = true
  enable_execute_command  = false
  force_new_deployment    = true

  health_check_grace_period_seconds = var.enable_load_balancer ? 0 : null

  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []

    content {
      container_name   = var.ecs_service_name
      container_port   = var.ecs_container_port
      target_group_arn = aws_lb_target_group.alb[0].arn
    }
  }

  # Tasks are placed on container instances so as to leave the
  # least amount of unused CPU or memory. This strategy minimizes
  # the number of container instances in use.
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  # TODO before changing other configuration we should test this
  service_connect_configuration {
    enabled = var.enable_service_connect
  }

  timeouts {
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      desired_count
    ]
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE THE SERVICE

# AUTO SCALING USING APP AUTOSCALING POLICIES AND TARGET

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE AUTOSCALING TARGET
# -------------------------------------------

resource "aws_appautoscaling_target" "service" {
  count = var.enable_service_auto_scaling && !var.create_scheduled_task ? 1 : 0

  max_capacity = max(var.auto_scaling_max_number_of_tasks, var.desired_number_of_tasks)
  min_capacity = min(var.auto_scaling_min_number_of_tasks, var.desired_number_of_tasks)

  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.service
  ]
}


# -------------------------------------------
# CREATE THE AUTOSCALING POLICY
# -------------------------------------------

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_service_auto_scaling && !var.create_scheduled_task ? 1 : 0

  name               = "${var.ecs_service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    target_value = var.auto_scaling_cpu_util_threshold
  }

  depends_on = [
    aws_ecs_service.service
  ]
}

resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_service_auto_scaling && !var.create_scheduled_task ? 1 : 0

  name               = "${var.ecs_service_name}-mem-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    target_value = var.auto_scaling_memory_util_threshold
  }

  depends_on = [
    aws_ecs_service.service
  ]
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE THE ECS

# TASK-DEFINITION AND LOG GROUP

# ------------------------------------------------------------

data "aws_region" "current" {}

locals {
  cloudwatch_log_group_name = "/ecs/${var.ecs_service_name}"
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group  = local.cloudwatch_log_group_name
      awslogs-region = data.aws_region.current.name
    }
  }

  repositoryCredentials = {
    credentialsParameter = var.docker_credential_secretsmanager_arn
  }

  # TODO we need to figure out how to enable good health checks
  # healthCheck = {
  #   command     = ["CMD-SHELL", "curl -f http://localhost:${var.ecs_container_port}/ || exit 1"]
  #   interval    = 30
  #   retries     = 5
  #   startPeriod = 0
  #   timeout     = 5
  # }

  # This allows us to query both the existing as well as Terraform's state and get
  # and get the max version of either source, useful for when external resources
  # update the container definition
  max_task_def_revision = max(aws_ecs_task_definition.task.revision, data.aws_ecs_task_definition.task.revision)
  task_definition       = "${aws_ecs_task_definition.task.family}:${local.max_task_def_revision}"

  # If the container image is not specified, then the latest version of the
  # essential container definition image will be used.
  lookup_deployed_image = var.ecs_container_image == ""

  # If the container image is not specified, then the latest version of the
  # essential container definition image will be used.
  image = !local.lookup_deployed_image ? var.ecs_container_image : data.aws_ecs_container_definition.task[0].image
}

data "aws_ecs_service" "service" {
  count = local.lookup_deployed_image && !var.create_scheduled_task ? 1 : 0

  cluster_arn  = data.aws_ecs_cluster.cluster.arn
  service_name = var.ecs_service_name
}

# This will get the latest container definition from the task definition
# that is currently deployed and use that as the image for new container
# definitions
data "aws_ecs_container_definition" "task" {
  count = local.lookup_deployed_image && !var.create_scheduled_task ? 1 : 0

  task_definition = data.aws_ecs_service.service[0].task_definition
  container_name  = var.ecs_service_name
}

# This allows us to query both the existing as well as Terraform's state and get
# and get the max version of either source, useful for when external resources
# update the container definition
data "aws_ecs_task_definition" "task" {
  task_definition = aws_ecs_task_definition.task.family

  depends_on = [
    aws_ecs_task_definition.task
  ]
}

# -------------------------------------------
# CREATE THE ECS TASK DEFINITION
# -------------------------------------------

resource "aws_ecs_task_definition" "task" {
  family = var.ecs_service_name

  cpu          = 256
  memory       = 256
  network_mode = var.create_scheduled_task ? "awsvpc" : "bridge"

  execution_role_arn = aws_iam_role.task_execution.arn
  # task_role_arn      = "" # TODO add this in development

  container_definitions = jsonencode([
    {
      name = var.ecs_service_name

      image = local.image

      repositoryCredentials = var.docker_credential_secretsmanager_arn != "" ? local.repositoryCredentials : null

      portMappings = [{
        containerPort = var.ecs_container_port
      }]

      # Environment Variables and Secrets are both string maps with
      # the same key/value structure. They are mapped to the following
      # structure for the container definition:
      #
      # environment = [{ "name" : "", "value" : ""}]
      # secrets = [{ "name" : "", "valueFrom" : ""}]
      #
      environment = [for k, v in var.ecs_container_environment_variables : { name = k, value = v }]
      secrets     = [for k, v in var.ecs_container_secrets : { name = k, valueFrom = v }]

      logConfiguration = var.enable_container_logs ? local.log_configuration : null

      # healthCheck = !var.create_scheduled_task ? local.healthCheck : null
    }
  ])

  requires_compatibilities = var.create_scheduled_task ? ["FARGATE"] : ["EC2"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  depends_on = [
    aws_cloudwatch_log_group.task
  ]

  lifecycle {
    create_before_destroy = true
  }
}


# -------------------------------------------
# CREATE THE ECS LOG GROUP FOR THE ESSENTIAL DEFINITION
# -------------------------------------------

resource "aws_cloudwatch_log_group" "task" {
  count = var.enable_container_logs ? 1 : 0

  name              = local.cloudwatch_log_group_name
  retention_in_days = 30

  lifecycle {
    prevent_destroy = false
  }
}


# -------------------------------------------
# CREATE THE TASK EXECUTION IAM ROLE
# -------------------------------------------

locals {
  # The secrets manager ARNs are used to create the IAM policy
  # for the task execution role. The docker credentials secret
  # is also included in the list of secrets manager ARNs.
  docker_credentials_secret_arn = var.docker_credential_secretsmanager_arn != "" ? [var.docker_credential_secretsmanager_arn] : []
  secrets_manager_arns          = concat([for k, v in var.ecs_container_secrets : v], local.docker_credentials_secret_arn)
}

resource "aws_iam_role" "task_execution" {
  name = "${var.ecs_service_name}-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "task_execution" {
  count = length(local.secrets_manager_arns) > 0 ? 1 : 0

  name = "${var.ecs_service_name}-secretsmanager-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = local.secrets_manager_arns
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  count = length(local.secrets_manager_arns) > 0 ? 1 : 0

  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.task_execution[0].arn
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# SCHEDULED TASKS. WHEN A SCHEDULED TASK IS

# CONFIGURED, THE ECS SERVICE RESOURCE SHOULD

# NOT BE CREATED.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE ECS TARGET FOR THE RULE
# -------------------------------------------

resource "aws_cloudwatch_event_target" "scheduled" {
  count = var.create_scheduled_task ? 1 : 0

  target_id = "${var.ecs_service_name}-scheduled"
  arn       = data.aws_ecs_cluster.cluster.arn
  rule      = aws_cloudwatch_event_rule.scheduled[0].name
  role_arn  = aws_iam_role.scheduled[0].arn

  ecs_target {
    task_count          = var.desired_number_of_tasks
    task_definition_arn = local.task_definition
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = var.scheduled_task_subnet_ids
      security_groups  = var.scheduled_task_security_group_ids
      assign_public_ip = var.scheduled_task_assign_public_ip
    }
  }
}


# -------------------------------------------
# CREATE THE ECS IAM ROLE FOR THE EVENT
# -------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  count = var.create_scheduled_task ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduled" {
  count = var.create_scheduled_task ? 1 : 0

  name               = "${var.ecs_service_name}-scheduled"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}


# -------------------------------------------
# CREATE THE ECS IAM POLICY FOR THE EVENT
# -------------------------------------------

data "aws_iam_policy_document" "scheduled" {
  count = var.create_scheduled_task ? 1 : 0

  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  statement {
    actions   = ["ecs:RunTask"]
    resources = ["${aws_ecs_task_definition.task.arn_without_revision}:*"]
  }
}

resource "aws_iam_role_policy" "scheduled" {
  count = var.create_scheduled_task ? 1 : 0

  name   = "${var.ecs_service_name}-run-task"
  role   = aws_iam_role.scheduled[0].id
  policy = data.aws_iam_policy_document.scheduled[0].json
}


# -------------------------------------------
# CREATE THE RULE TO TRIGGER THE ECS TASK
# -------------------------------------------

resource "aws_cloudwatch_event_rule" "scheduled" {
  count = var.create_scheduled_task ? 1 : 0

  name        = "${var.ecs_service_name}-rule"
  description = "Trigger the ECS task by schedule or event."

  event_pattern       = var.scheduled_task_event_pattern != null ? jsonencode(var.scheduled_task_event_pattern) : null
  schedule_expression = var.scheduled_task_cron_expression != "" ? var.scheduled_task_cron_expression : null

  depends_on = [aws_ecs_task_definition.task]
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# THE ALB ATTACHMENT FOR THE ECS SERVICE

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE LISTENER RULE TO ATTACH TO THE EXISTING LISTENER
# -------------------------------------------

resource "aws_lb_listener_rule" "alb" {
  count = var.enable_load_balancer ? 1 : 0

  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb[0].arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  depends_on = [
    aws_lb_target_group.alb
  ]
}


# -------------------------------------------
# CREATE THE TARGET GROUP FOR THE RULE TO DIRECT TRAFFIC TO
# -------------------------------------------

resource "aws_lb_target_group" "alb" {
  count = var.enable_load_balancer ? 1 : 0

  name     = var.ecs_service_name
  port     = var.ecs_container_port
  protocol = "HTTP"

  vpc_id = var.lb_target_group_vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/"
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}


