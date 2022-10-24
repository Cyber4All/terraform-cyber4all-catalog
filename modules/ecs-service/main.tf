# ---------------------------------------------------------------------------------------------------------------------
# CREATE ECS TASK DEFINITION
#
# Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
# AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "task" {
  family                = var.task_family
  container_definitions = var.container_definitions

  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities

  skip_destroy = true

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  # ----------------------------------------------------
  # HARDWARE SIZES
  # ----------------------------------------------------
  cpu = var.task_cpu
  dynamic "ephemeral_storage" {
    for_each = length(keys(var.ephemeral_storage)) == 0 ? [] : [var.ephemeral_storage]
    content {
      size_in_gib = lookup(ephemeral_storage.value, "size_in_gib", null)
    }
  }
  memory = var.task_memory

  # ----------------------------------------------------
  # ECS TASK AUTH
  # ----------------------------------------------------
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  /* inference_accelerator {} */
  /* ipc_mode = "shareable" */
  /* pid_mode = host | task */
  /* placement_constraints {} */
  /* proxy_configuration {} */
  /* tags = {} */
  /* volume {} */
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE ECS SERVICE
#
# Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
# AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name = var.service_name

  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.task.arn

  launch_type             = var.launch_type
  enable_ecs_managed_tags = true

  # ----------------------------------------------------
  # DEPLOYMENT CONFIG
  # ----------------------------------------------------
  desired_count                     = var.desired_count
  enable_execute_command            = false
  force_new_deployment              = true
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  # ----------------------------------------------------
  # SERVICE DISCOVERY CONFIG
  # ----------------------------------------------------
  service_registries {
    registry_arn   = var.service_registry_arn
    port           = var.service_registry_port
    container_name = var.container_name
    container_port = var.container_port
  }

  # ----------------------------------------------------
  # LOAD BALANCER CONFIG
  # ----------------------------------------------------

  dynamic "load_balancer" {
    for_each = length(keys(var.load_balancer)) == 0 ? [] : [var.load_balancer]

    content {
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
      container_name   = lookup(load_balancer.value, "container_name", null)
      container_port   = lookup(load_balancer.value, "container_port", null)
    }
  }

  # ----------------------------------------------------
  # NETWORK CONFIG
  # ----------------------------------------------------
  network_configuration {
    subnets          = var.service_subnets
    security_groups  = [var.service_security_group_id]
    assign_public_ip = var.assign_public_ip # can be true for FARGATE
  }

  # ----------------------------------------------------
  # TASK PLACEMENT
  # ----------------------------------------------------
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  /* capacity_provider_strategy {} */
  /* deployment_circuit_breaker {} */
  /* deployment_controller {} */
  /* deployment_maximum_percent = 200 */
  /* deployment_minimum_healthy_percent = 100 */
  /* iam_role = null */
  /* placement_constraints {} */
  /* platform_version = "LATEST" */
  /* propagate_tags = null */
  /* scheduling_strategy = "REPLICA" */
  /* tags = {} */
  /* wait_for_steady_state = false */
}