#################################
# ecs
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
#################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.1"

  default_capacity_provider_use_fargate = false

  cluster_name = "${var.project_name}-cluster"

  cluster_configuration = var.s3_log_bucket_name ? {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        s3_bucket_encryption_enabled = true
        s3_bucket_name               = var.s3_log_bucket_name
      }
    }
  } : {}

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn

      managed_termination_protection = "ENABLED"

      managed_scaling = var.managed_scaling

      default_capacity_provider_strategy = var.default_capacity_provider_strategy
    }
  }

  cluster_settings = {
    "name" : "containerInsights",
    "value" : "enabled"
  }

  ##################################
  # Defaults
  ##################################
  # create = true
  # fargate_capacity_providers = {}
  # tags = {}
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

  ##################################
  # Defaults
  ##################################
  # auto_groups (see registry page, too long to include)
  # computed_egress_rules = []
  # computed_egress_with_cidr_blocks = []
  # computed_egress_with_ipv6_cidr_blocks = []
  # computed_egress_with_self = []
  # computed_egress_with_source_security_group_id = []
  # computed_ingress_rules = []
  # computed_ingress_with_cidr_blocks = []
  # computed_ingress_with_ipv6_cidr_blocks = []
  # computed_ingress_with_self = []
  # computed_ingress_with_source_security_group_id = []
  # create = true
  # create_sg = true
  # create_timeout = "10m"
  # delete_timeout = "15m"
  # egress_cidr_blocks = [ "0.0.0.0/0" ]
  # egress_ipv6_cidr_blocks = [ "::/0" ]
  # egress_prefix_list_ids = []
  # egress_rules = []
  # egress_with_ipv6_cidr_blocks = []
  # egress_with_self = []
  # egress_with_source_security_group_id = []
  # ingress_cidr_blocks = []
  # ingress_ipv6_cidr_blocks = []
  # ingress_prefix_list_ids = []
  # ingress_rules = []
  # ingress_with_ipv6_cidr_blocks = []
  # ingress_with_self = []
  # ingress_with_source_security_group_id = []
  # number_of_computed_egress_rules = 0
  # number_of_computed_egress_with_cidr_blocks = 0
  # number_of_computed_egress_with_ipv6_cidr_blocks = 0
  # number_of_computed_egress_with_self = 0
  # number_of_computed_egress_with_source_security_group_id = 0
  # number_of_computed_ingress_rules = 0
  # number_of_computed_ingress_with_cidr_blocks = 0
  # number_of_computed_ingress_with_ipv6_cidr_blocks = 0
  # number_of_computed_ingress_with_self = 0
  # number_of_computed_ingress_with_source_security_group_id = 0
  # putin_khuylo = true
  # revoke_rules_on_delete = false
  # rules (see registry page, too long to include)
  # security_group_id = null
  # tags = {}
  # use_name_prefix = true
}

#################################
# Auto-Scaling Group
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
#################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.subnets
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
  iam_instance_profile_name   = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : "${var.project_name}-instance-profile"
  iam_role_name               = "${var.project_name}-iam-role-profile"
  iam_role_description        = var.iam_role_description
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  credit_specification = {
    cpu_credits = "standard"
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

  ##################################
  # Defaults
  ##################################
  # availability_zones = null
  # capacity_reservation_specification = {}
  # cpu_options = {}
  # create = true
  # create_scaling_policy = true
  # default_cooldown = null
  # default_version = null
  # delete_timeout = null
  # disable_api_termination = null
  # ebs_optimized = null
  # elastic_gpu_specifications = {}
  # elastic_inference_accelerator = {}
  # enable_monitoring = true
  # enclave_options = {}
  # force_delete = null
  # health_check_grace_period = null
  # hibernation_options = {}
  # iam_instance_profile_arn = null
  # iam_role_path = null
  # iam_role_permissions_boundary = null
  # iam_role_tags = {}
  # iam_role_use_name_prefix = true
  # ignore_desired_capacity_changes = false
  # initial_lifecycle_hooks = []
  # instance_initiated_shutdown_behavior = null
  # instance_market_options = {}
  # instance_name = ""
  # instance_refresh = {}
  # instance_requirements = {}
  # kernel_id = null
  # key_name = null
  # launch_template = null
  # launch_template_use_name_prefix = true
  # launch_template_version = null
  # license_specifications = {}
  # load_balancers = []
  # maintenance_options = {}
  # max_instance_lifetime = null
  # metadata_options = {}
  # metrics_granularity = null
  # min_elb_capacity = null
  # mixed_instances_policy = null
  # network_interfaces = []
  # placement = {}
  # placement_group = null
  # private_dns_name_options = {}
  # putin_khuylo = true
  # ram_disk_id = null
  # scaling_policies = {}
  # schedules = {}
  # service_linked_role_arn = null
  # suspended_processes = []
  # tag_specifications = []
  # tags = {}
  # target_group_arns = []
  # termination_policies = []
  # use_mixed_instances_policy = false
  # use_name_prefix = true
  # wait_for_capacity_timeout = null
  # wait_for_elb_capacity = null
  # warm_pool = {}
}
