#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  for_each = {
    one = {
      instance_type = "t2.micro"
    }
    two = {
      instance_type = "t2.large"
    }
  }

  name                = "example-${each.key}"
  vpc_zone_identifier = module.vpc.public_subnets
  min_size            = 1
  max_size            = 1

  # launch template
  create_launch_template      = true
  launch_template_name        = "example-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true
  image_id                    = "ami-06e07b42f153830d8"
  instance_type               = each.value.instance_type
  user_data                   = base64encode(templatefile("${path.module}/containerAgent.sh", { CLUSTER_NAME = "example-ecs-ec2" })) # abstract name to vars, can't reference ecs module, cyclical dependency


  security_groups = [var.security_group_ids]

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
#################################
# Supporting resources
#################################
#################################


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