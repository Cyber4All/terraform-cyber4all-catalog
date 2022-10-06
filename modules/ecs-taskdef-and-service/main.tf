# Creates an ECS task definition in AWS
# Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
# AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
resource "aws_ecs_task_definition" "example" {
  family                   = var.ecs_taskdef_family
  container_definitions    = var.ecs_taskdef_container_definitions
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
}

# Creates an ECS service in AWS
# Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
# AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
resource "aws_ecs_service" "example" {
  name            = var.ecs_service_name
  task_definition = aws_ecs_task_definition.example.arn
  cluster         = var.ecs_service_cluster_arn
  desired_count   = var.ecs_service_num_tasks

  network_configuration {
    subnets         = concat(var.ecs_service_public_subnets, var.ecs_service_private_subnets)
    security_groups = [var.ecs_service_security_group_id]
  }
}