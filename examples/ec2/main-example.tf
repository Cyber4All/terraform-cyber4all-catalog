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
  project_name               = "example"
  launch_template_ami        = "ami-06e07b42f153830d8"
  instance_type              = "t2.micro"
  ingress_with_cidr_blocks   = ["0.0.0.0/0"]
  vpc_cidr                   = "10.99.0.0/18"
  ingress_rules              = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules               = ["all-all"]
  public_subnets             = ["10.99.0.0/24", "10.99.1.0/24"]
  private_subnets            = ["10.99.3.0/24", "10.99.4.0/24"]
  asg_max_size               = 1
  security_group_description = "example security group"
}

#################################
# vpc
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "${local.project_name}-vpc"
  cidr = local.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

}

#################################
# security group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
#################################
module "security-group" {
  source  = "../../modules/security-group"
  project_name = local.project_name
  vpc_id  = module.vpc.vpc_id

  # allow ssh from anywhere
  ingress_cidr_blocks = local.ingress_with_cidr_blocks
  ingress_rules       = local.ingress_rules
  egress_rules        = local.egress_rules
}

#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "../../modules/autoscaling"
  project_name    = local.project_name
  private_subnets = module.vpc.private_subnets
  asg_max_size    = local.asg_max_size
  vpc_id          = module.vpc.vpc_id
  security_group_ids = [module.security-group.security_group_id]

  # launch template
  launch_template_ami = local.launch_template_ami
  instance_type       = local.instance_type
}
#################################
# ecs
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest
#################################
module "ecs-cluster" {
  source  = "../../modules/ecs-cluster"
  project_name = local.project_name
  autoscaling_group_arn = module.autoscaling.autoscaling_group_arn
}