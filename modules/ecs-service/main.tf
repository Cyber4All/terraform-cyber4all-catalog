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
  requires_compatibilities = ["EC2", "FARGATE"]

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  # ----------------------------------------------------
  # HARDWARE SIZES
  # ----------------------------------------------------
  cpu = var.task_cpu
  ephemeral_storage {
    size_in_gib = var.task_ephemeral_storage
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
  /* skip_destroy = false */
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
  health_check_grace_period_seconds = 60

  # ----------------------------------------------------
  # LOAD BALANCER CONFIG
  # ----------------------------------------------------
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
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
  /* service_registries {} */
  /* tags = {} */
  /* wait_for_steady_state = false */
}