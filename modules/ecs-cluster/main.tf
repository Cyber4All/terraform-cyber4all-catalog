terraform {
  experiments = [module_variable_optional_attrs]
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

      managed_termination_protection = var.managed_termination_protection

      managed_scaling = var.managed_scaling

      default_capacity_provider_strategy = var.default_capacity_provider_strategy
    }
  }
}

##################################
# Required resources
##################################


#################################
# security group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
#################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.project_name}-sg"
  description = var.security_group_description
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks
}

#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name                = "${var.project_name}-asg"
  vpc_zone_identifier = concat(var.private_subnets, var.public_subnets)
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.desired_capacity
  health_check_type   = "EC2"

  # launch template
  create_launch_template      = true
  launch_template_name        = "${var.project_name}-launch-template"
  launch_template_description = var.launch_template_description
  update_default_version      = true
  image_id                    = var.launch_template_ami
  instance_type               = var.instance_type
  user_data                   = base64encode(templatefile("${path.module}/containerAgent.sh", { CLUSTER_NAME = "${var.project_name}-cluster" }))

  block_device_mappings = var.block_device_mappings

  security_groups = [module.security_group.security_group_id]

  # iam role creation
  create_iam_instance_profile = true
  iam_role_name               = "${var.project_name}-iam-role-profile"
  iam_role_description        = var.iam_role_description
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  protect_from_scale_in = true
  capacity_rebalance    = var.capacity_rebalance
  create_schedule       = false

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity", 
    "GroupMinSize", 
    "GroupMaxSize", 
    "GroupInServiceInstances", 
    "GroupPendingInstances", 
    "GroupStandbyInstances", 
    "GroupStandbyCapacity", 
    "GroupTerminatingCapacity", 
    "GroupTerminatingInstances", 
    "GroupTotalCapacity", 
    "GroupTotalInstances"
    ]
}
