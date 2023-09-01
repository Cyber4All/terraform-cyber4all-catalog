# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER CONFIG
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/4.1.1
# 
# aws_ecs_cluster: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# ---------------------------------------------------------------------------------------------------------------------
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.1"

  cluster_name = "${var.project_name}-cluster"

  # ----------------------------------------------------
  # LOGGING CONFIG
  # ----------------------------------------------------
  cluster_configuration = var.log_group_name != null ? {
    execute_command_configuration = {
      logging = "OVERRIDE"

      log_configuration = {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = var.log_group_name
      }
    }
  } : {}

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  /* autoscaling_capacity_providers = {} */
  /* cluster_settings = { "name": "containerInsights", "value": "enabled" } */
  /* create = true */
  /* default_capacity_provider_use_fargate = true */
  /* fargate_capacity_providers = {} */
  /* tags = {} */
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP (SG) FOR ASG
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.15.0
#
# aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# aws_security_group_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# ---------------------------------------------------------------------------------------------------------------------
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.15.0"

  name        = "${var.project_name}-sg"
  description = var.sg_description
  vpc_id      = var.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules

  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  /* auto_groups (see registry page, too long to include) */
  /* computed_egress_rules = [] */
  /* computed_egress_with_cidr_blocks = [] */
  /* computed_egress_with_ipv6_cidr_blocks = [] */
  /* computed_egress_with_self = [] */
  /* computed_egress_with_source_security_group_id = [] */
  /* computed_ingress_rules = [] */
  /* computed_ingress_with_cidr_blocks = [] */
  /* computed_ingress_with_ipv6_cidr_blocks = [] */
  /* computed_ingress_with_self = [] */
  /* computed_ingress_with_source_security_group_id = [] */
  /* create = true */
  /* create_sg = true */
  /* create_timeout = "10m" */
  /* delete_timeout = "15m" */
  /* egress_cidr_blocks = [ "0.0.0.0/0" ] */
  /* egress_ipv6_cidr_blocks = [ "::/0" ] */
  /* egress_prefix_list_ids = [] */
  /* egress_with_ipv6_cidr_blocks = [] */
  /* egress_with_self = [] */
  /* egress_with_source_security_group_id = [] */
  /* ingress_cidr_blocks = [] */
  /* ingress_ipv6_cidr_blocks = [] */
  /* ingress_prefix_list_ids = [] */
  /* ingress_with_ipv6_cidr_blocks = [] */
  /* ingress_with_self = [] */
  /* ingress_with_source_security_group_id = [] */
  /* number_of_computed_egress_rules = 0 */
  /* number_of_computed_egress_with_cidr_blocks = 0 */
  /* number_of_computed_egress_with_ipv6_cidr_blocks = 0 */
  /* number_of_computed_egress_with_self = 0 */
  /* number_of_computed_egress_with_source_security_group_id = 0 */
  /* number_of_computed_ingress_rules = 0 */
  /* number_of_computed_ingress_with_cidr_blocks = 0 */
  /* number_of_computed_ingress_with_ipv6_cidr_blocks = 0 */
  /* number_of_computed_ingress_with_self = 0 */
  /* number_of_computed_ingress_with_source_security_group_id = 0 */
  /* putin_khuylo = true */
  /* revoke_rules_on_delete = false */
  /* rules (see registry page, too long to include) */
  /* security_group_id = null */
  /* tags = {} */
  /* use_name_prefix = true */
}

# ---------------------------------------------------------------------------------------------------------------------
# AUTO SCALING GROUP (ASG)
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/6.5.2
#
# aws_autoscaling_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
# aws_autoscaling_policy: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy
# aws_autoscaling_schedule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule
# aws_iam_instance_profile: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
# aws_iam_role: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# aws_iam_role_policy_attachment: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
# aws_launch_template: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
# ---------------------------------------------------------------------------------------------------------------------
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name = "${var.project_name}-asg"

  # ----------------------------------------------------
  # ASG CONFIG
  # ----------------------------------------------------
  vpc_zone_identifier = var.subnet_ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type = "EC2"

  protect_from_scale_in = true
  capacity_rebalance    = var.capacity_rebalance

  create_schedule = false

  enabled_metrics = var.enabled_metrics

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # ----------------------------------------------------
  # IAM CONFIG
  # ----------------------------------------------------
  create_iam_instance_profile = true
  iam_instance_profile_name   = "${var.project_name}-ip"
  iam_role_name               = "${var.project_name}-role"
  iam_role_description        = var.iam_role_description
  iam_role_policies           = var.iam_role_policies

  # ----------------------------------------------------
  # LAUNCH TEMPLATE CONFIG
  # ----------------------------------------------------
  create_launch_template      = true
  launch_template_name        = "${var.project_name}-lt"
  launch_template_description = var.launch_template_description

  image_id               = var.ami_id
  user_data              = base64encode(templatefile("${path.module}/helpers/containerAgent.sh", { CLUSTER_NAME = "${var.project_name}-cluster" }))
  update_default_version = true
  instance_type          = var.instance_type
  block_device_mappings  = var.block_device_mappings

  security_groups = [module.security_group.security_group_id]

  credit_specification = {
    cpu_credits = "standard"
  }

  metadata_options = {
    http_tokens = "required"
  }

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  /* availability_zones = null */
  /* capacity_reservation_specification = {} */
  /* cpu_options = {} */
  /* create = true */
  /* create_scaling_policy = true */
  /* default_cooldown = null */
  /* default_version = null */
  /* delete_timeout = null */
  /* disable_api_termination = null */
  /* ebs_optimized = null */
  /* elastic_gpu_specifications = {} */
  /* elastic_inference_accelerator = {} */
  /* enable_monitoring = true */
  /* enclave_options = {} */
  /* force_delete = null */
  /* health_check_grace_period = null */
  /* hibernation_options = {} */
  /* iam_instance_profile_arn = null */
  /* iam_role_path = null */
  /* iam_role_permissions_boundary = null */
  /* iam_role_tags = {} */
  /* iam_role_use_name_prefix = true */
  /* ignore_desired_capacity_changes = false */
  /* initial_lifecycle_hooks = [] */
  /* instance_initiated_shutdown_behavior = null */
  /* instance_market_options = {} */
  /* instance_name = "" */
  /* instance_refresh = {} */
  /* instance_requirements = {} */
  /* kernel_id = null */
  /* key_name = null */
  /* launch_template = null */
  /* launch_template_use_name_prefix = true */
  /* launch_template_version = null */
  /* license_specifications = {} */
  /* load_balancers = [] */
  /* maintenance_options = {} */
  /* max_instance_lifetime = null */
  /* metadata_options = {} */
  /* metrics_granularity = null */
  /* min_elb_capacity = null */
  /* mixed_instances_policy = null */
  /* network_interfaces = [] */
  /* placement = {} */
  /* placement_group = null */
  /* private_dns_name_options = {} */
  /* putin_khuylo = true */
  /* ram_disk_id = null */
  /* scaling_policies = {} */
  /* schedules = {} */
  /* service_linked_role_arn = null */
  /* suspended_processes = [] */
  /* tag_specifications = [] */
  /* tags = {} */
  /* target_group_arns = [] */
  /* termination_policies = [] */
  /* use_mixed_instances_policy = false */
  /* use_name_prefix = true */
  /* wait_for_capacity_timeout = null */
  /* wait_for_elb_capacity = null */
  /* warm_pool = {} */
}
