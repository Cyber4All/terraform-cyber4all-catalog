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

locals {
  project_name = "example"
}


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

module "ecs-cluster" {
  source = "../../modules/ecs-cluster"

  project_name        = "${local.project_name}"
  launch_template_ami = "ami-06e07b42f153830d8"
  instance_type       = "t2.micro"
  asg_max_size        = 2
  vpc_id              = module.vpc.vpc_id
  s3_log_bucket_name  = ""

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

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

  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ecs-taskdef-and-service" {
  source = "../../modules/ecs-taskdef-and-service"

  # Task Definition Parameters
  ecs_taskdef_family                = "${local.project_name}-taskdef"
  ecs_taskdef_container_definitions = file("exampleTaskDef.json")

  # Service Parameters
  ecs_service_name        = "${local.project_name}-service"
  ecs_service_cluster_arn = module.ecs-cluster.cluster_arn
  ecs_service_num_tasks   = 1

  ecs_service_public_subnets    = module.vpc.public_subnets
  ecs_service_private_subnets   = module.vpc.private_subnets
  ecs_service_security_group_id = module.ecs-cluster.security_group_id

}