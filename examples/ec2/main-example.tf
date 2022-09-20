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
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]

}

#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name                = "example-asg"
  vpc_zone_identifier = module.vpc.public_subnets
  min_size            = 1
  max_size            = 1

  # launch template
  create_launch_template      = true
  launch_template_name        = "example-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true
  image_id                    = "ami-06e07b42f153830d8"
  instance_type               = "t2.micro"
  user_data                   = base64encode(templatefile("${path.module}/containerAgent.sh", { CLUSTER_NAME = "example-ecs-ec2" })) # abstract name to vars, can't reference ecs module, cyclical dependency


  security_groups = [module.security_group.security_group_id]

  # iam role creation
  create_iam_instance_profile = true
  iam_role_name               = "example-iam"
  iam_role_description        = "ECS role for"
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
# Launch Template for ASG
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
#################################
# resource "aws_launch_template" "example_lt" {
#   name                   = "example-lt"
#   image_id               = "ami-06e07b42f153830d8"
#   instance_type          = "t2.micro"
#   # vpc_security_group_ids = [module.security_group.security_group_id]

#   update_default_version = true
#   # network_interfaces {
#   #   associate_public_ip_address = true
#   #   security_groups = [module.security_group.security_group_id]
#   # }

#   # iam_instance_profile {
#   #   arn = module.iam_iam-assumable-role.iam_instance_profile_arn
#   # }

#   user_data = base64encode(templatefile("${path.module}/containerAgent.sh", { CLUSTER_NAME = "example-ecs-ec2" })) # abstract name to vars, can't reference ecs module, cyclical dependency
# }



#################################
# ecs
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest
#################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.1"

  default_capacity_provider_use_fargate = false

  cluster_name = "example-ecs-ec2"

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }


}