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
    key    = "live/example/ec2/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "competency-service-terraform-locks"
    encrypt        = true
  }
}

#################################
# vpc
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "example-vpc"
  cidr = "10.99.0.0/18"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.99.0.0/24", "10.99.1.0/24"]
  private_subnets = ["10.99.3.0/24", "10.99.4.0/24"]

}

#################################
# security group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
#################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "example-security-group"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  # allow ssh from anywhere
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

}

#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name    = "example-asg"
  launch_template = aws_launch_template.example_lt.name
  min_size = 0
  max_size = 1
}

#################################
# Launch Template for ASG
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
#################################
resource "aws_launch_template" "example_lt" {
  name = "example-lt"
  image_id = "ami-015baecf2e21c75c0"
  instance_type = "t2.micro"
  vpc_security_group_ids = module.security_group.security_group_id

  block_device_mappings {
    device_name = "/dev/sda1"
    no_device   = 1
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 30
      volume_type           = "gp2"
    }
  }
}

#################################
# ecs
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest
#################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.1"

  cluster_name = "example-ecs-ec2"

  cluster_configuration = {
    one = {
      autoscaling_group_arn = module.autoscaling.autoscaling_group_arn
    }
  }
}