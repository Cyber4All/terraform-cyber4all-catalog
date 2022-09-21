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

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.avail_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

}

#################################
# security group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
#################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.project_name}-sg"
  description = var.security_group_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks
  ingress_rules       = var.ingress_rules
  egress_rules        = var.egress_rules
}

#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name                = "${var.project_name}-asg"
  vpc_zone_identifier = module.vpc.public_subnets
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size

  # launch template
  create_launch_template      = true
  launch_template_name        = "${var.project_name}-launch-template"
  launch_template_description = var.launch_template_description
  update_default_version      = true
  image_id                    = var.launch_template_ami
  instance_type               = var.instance_type
  user_data                   = base64encode(templatefile("${path.module}/containerAgent.sh", { CLUSTER_NAME = "example-ecs-ec2" })) # abstract name to vars, can't reference ecs module, cyclical dependency


  security_groups = [module.security_group.security_group_id]

  # iam role creation
  create_iam_instance_profile = true
  iam_role_name               = "${var.project_name}-iam-role"
  iam_role_description        = var.iam_role_description
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  protect_from_scale_in = true
}

#################################
# ecs
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest
#################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.1"

  default_capacity_provider_use_fargate = false

  cluster_name = "${var.project_name}-cluster"

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
    }
  }
}