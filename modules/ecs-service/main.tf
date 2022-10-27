# ---------------------------------------------------------------------------------------------------------------------
# CLOUD MAP SERVICE DISCOVERY REGISTRY
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service
#
# aws docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_service_discovery_service" "registry" {
  name        = var.service_name
  description = var.service_discovery_description

  dns_config {
    namespace_id = var.dns_namespace_id

    dns_records {
      ttl  = 60
      type = "SRV"
    }
  }

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  /* health_check_config {} */
  /* force_destroy = false */
  /* health_check_custom_config {} */
  /* namespace_id = null */
  /* tags = {} */
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK DEFINITION
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
#
# aws docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "task" {
  family                = var.service_name
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
# ECS SERVICE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
# 
# aws docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
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
  dynamic "service_registries" {
    for_each = length(keys(var.service_registries)) == 0 ? [] : [var.service_registries]

    content {
      registry_arn   = aws_service_discovery_service.registry.arn
      port           = lookup(service_registries.value, "port", null)           # Port value used if your Service Discovery service specified an SRV record.
      container_name = lookup(service_registries.value, "container_name", null) # Port value, already specified in the task definition, to be used for your service discovery service.
      container_port = lookup(service_registries.value, "container_port", null) # Container name value, already specified in the task definition, to be used for your service discovery service.
    }
  }

  # ----------------------------------------------------
  # LOAD BALANCER CONFIG
  # ----------------------------------------------------
  dynamic "load_balancer" {
    for_each = length(keys(var.load_balancer)) == 0 ? [] : [var.load_balancer]

    content {
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null) # ARN of the Load Balancer target group to associate with the service.
      container_name   = lookup(load_balancer.value, "container_name", null)   # Name of the container to associate with the load balancer (as it appears in a container definition).
      container_port   = lookup(load_balancer.value, "container_port", null)   # Port on the container to associate with the load balancer.
    }
  }

  # ----------------------------------------------------
  # NETWORK CONFIG
  # ----------------------------------------------------
  dynamic "network_configuration" {
    for_each = length(keys(var.network_configuration)) == 0 ? [] : [var.network_configuration]

    content {
      subnets          = lookup(network_configuration.value, "subnets", [])             # Subnets associated with the task or service.
      security_groups  = lookup(network_configuration.value, "security_groups", [])     # Security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used.
      assign_public_ip = lookup(network_configuration.value, "assign_public_ip", false) # Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false.
    }
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
  /* ordered_placement_strategy {} */
  /* placement_constraints {} */
  /* platform_version = "LATEST" */
  /* propagate_tags = null */
  /* scheduling_strategy = "REPLICA" */
  /* tags = {} */
  /* wait_for_steady_state = false */
}
