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

resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  container_definitions    = file("task-definitions/example1.json")
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
}