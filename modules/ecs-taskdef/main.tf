terraform {
  required_version = "1.2.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }

  backend "s3" {
    bucket = "competency-service-terraform-state"
    key    = "live/example/ecs/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "competency-service-terraform-locks"
    encrypt        = true
  }
}

# Creates an ECS task definition in AWS
# Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
# AWS Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
resource "aws_ecs_task_definition" "example" {
  family                   = var.family
  container_definitions    = file("task-definitions/example1.json")
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
}