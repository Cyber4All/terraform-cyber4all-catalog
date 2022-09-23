#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_subnets
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size

  # launch template
  create_launch_template      = true
  launch_template_name        = "${var.project_name}-launch-template"
  launch_template_description = var.launch_template_description
  update_default_version      = true
  image_id                    = var.launch_template_ami
  instance_type               = var.instance_type
  user_data                   = base64encode(templatefile("${path.module}/containerAgent.sh", { CLUSTER_NAME = "${var.project_name}-cluster" }))


  security_groups = var.security_group_ids

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
}
