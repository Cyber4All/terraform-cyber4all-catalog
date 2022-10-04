# resource "aws_ecs_capacity_provider" "capacity_example" {
#   name = "test"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn = var.auto_scaling_group_arn
#   }
# }

# Creates an ECS service in AWS
# Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
# AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
resource "aws_ecs_service" "example" {
  name            = var.name
  task_definition = var.task_def
  cluster         = var.cluster_arn
  desired_count   = var.num_tasks

  network_configuration {
    subnets         = concat(var.public_subnets, var.private_subnets)
    security_groups = [var.security_group_id]
  }

  # capacity_provider_strategy {
  #   capacity_provider = aws_ecs_capacity_provider.capacity_example.name
  #   weight = 1
  # }
}