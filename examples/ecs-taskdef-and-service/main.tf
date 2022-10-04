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

module "ecs-taskdef" {
  source = "../../modules/ecs-taskdef"

  family = "${local.project_name}-taskdef"
  container_definitions = file("./exampleTaskDef.json")
}

module "ecs-cluster" {
  source = "../../modules/ecs-cluster"

  project_name = "${local.project_name}-cluster"
  launch_template_ami = "ami-06e07b42f153830d8"
  instance_type = "t2.micro"
  asg_max_size = 2
  vpc_id = module.vpc.vpc_id
  s3_log_bucket_name = ""

  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
}

module "ecs-service" {
  source = "../../modules/ecs-service"

  name = "${local.project_name}-service"
  task_def = module.ecs-taskdef.ecs_task_def_arn
  cluster_arn = module.ecs-cluster.cluster_arn
  num_tasks = 2

  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  security_group_id = module.ecs-cluster.security_group_id

}