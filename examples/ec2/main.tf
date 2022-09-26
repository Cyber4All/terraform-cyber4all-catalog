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

locals {
  project_name = "example"
}

#################################
# vpc
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.project_name}-vpc"
  cidr = "10.99.0.0/18"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.99.0.0/24", "10.99.1.0/24"]
  private_subnets = ["10.99.3.0/24", "10.99.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

#################################
# ecs
# 
#################################
module "ecs-cluster" {
  source       = "../../modules/ecs-cluster"
  project_name = local.project_name

  vpc_id = module.vpc.vpc_id

  # allow ssh from anywhere
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks  = []

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  asg_max_size    = 1

  # launch template
  launch_template_ami = "ami-06e07b42f153830d8"
  instance_type       = "t2.micro"
}