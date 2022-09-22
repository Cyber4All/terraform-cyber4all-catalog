#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  for_each = {
      one = {
          name = "one"
      }
      two = {
          name = "two"
      }
  }

  name                = "example-asg"
  vpc_zone_identifier = path.module.vpc.public_subnets
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