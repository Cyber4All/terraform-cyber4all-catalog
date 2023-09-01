# ---------------------------------------------------------------------------------------------------------------------
# EXTERNAL ALB SECURITY GROUP
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.15.0
#
# aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# aws_security_group_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# 
# Recommended Rules:
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
#
# Inbound
#   0.0.0.0/0       listener                Allow all inbound traffic on the load balancer listener port  
# 
# Outbound
#   instance-sg     instance listener       Allow outbound traffic to instances on the instance listener port
#   instance-sg     health check            Allow outbound traffic to instances on the health check port
# ---------------------------------------------------------------------------------------------------------------------
module "external-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.15.0"

  create = var.create_external_alb

  name        = "${var.project_name}-ext-sg"
  description = var.external_sg_description
  vpc_id      = var.vpc_id

  ingress_rules = var.external_ingress_rules
  egress_rules  = var.external_egress_rules

  ingress_with_cidr_blocks = var.external_ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.external_egress_with_cidr_blocks

  ingress_with_source_security_group_id = var.external_ingress_with_source_security_group_id
  egress_with_source_security_group_id  = var.external_egress_with_source_security_group_id

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
  /* create_sg = true */
  /* create_timeout = "10m" */
  /* delete_timeout = "15m" */
  /* egress_cidr_blocks = [ "0.0.0.0/0" ] */
  /* egress_ipv6_cidr_blocks = [ "::/0" ] */
  /* egress_prefix_list_ids = [] */
  /* egress_with_ipv6_cidr_blocks = [] */
  /* egress_with_self = [] */
  /* ingress_cidr_blocks = [] */
  /* ingress_ipv6_cidr_blocks = [] */
  /* ingress_prefix_list_ids = [] */
  /* ingress_with_ipv6_cidr_blocks = [] */
  /* ingress_with_self = [] */
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
# INTERNAL ALB SECURITY GROUP
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.15.0
#
# aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# aws_security_group_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# 
# Recommended Rules: 
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
# 
# Inbound
#   VPC CIDR        listener                Allow all inbound traffic from the VPC CIDR on the load balancer listener port  
# 
# Outbound
#   instance-sg     instance listener       Allow outbound traffic to instances on the instance listener port
#   instance-sg     health check            Allow outbound traffic to instances on the health check port
# ---------------------------------------------------------------------------------------------------------------------
module "internal-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.15.0"

  create = var.create_internal_alb

  name        = "${var.project_name}-int-sg"
  description = var.internal_sg_description
  vpc_id      = var.vpc_id

  ingress_rules = var.internal_ingress_rules
  egress_rules  = var.internal_egress_rules

  ingress_with_cidr_blocks = var.internal_ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.internal_egress_with_cidr_blocks

  ingress_with_source_security_group_id = var.internal_ingress_with_source_security_group_id
  egress_with_source_security_group_id  = var.internal_egress_with_source_security_group_id

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
  /* create_sg = true */
  /* create_timeout = "10m" */
  /* delete_timeout = "15m" */
  /* egress_cidr_blocks = [ "0.0.0.0/0" ] */
  /* egress_ipv6_cidr_blocks = [ "::/0" ] */
  /* egress_prefix_list_ids = [] */
  /* egress_with_ipv6_cidr_blocks = [] */
  /* egress_with_self = [] */
  /* ingress_cidr_blocks = [] */
  /* ingress_ipv6_cidr_blocks = [] */
  /* ingress_prefix_list_ids = [] */
  /* ingress_with_ipv6_cidr_blocks = [] */
  /* ingress_with_self = [] */
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
# EXTERNAL APPLICATION LOAD BALANCER
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/8.1.0
#
# aws_lambda_permission: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
# aws_lb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# aws_lb_listener_certificate: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate
# aws_lb_listener_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# aws_lb_target_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# aws_lb_target_group_attachment: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
# ---------------------------------------------------------------------------------------------------------------------
module "external-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  drop_invalid_header_fields = true

  create_lb = var.create_external_alb

  name = "${var.project_name}-ext-alb"

  load_balancer_type = "application"

  # tfsec:ignore:aws-elb-alb-not-public
  internal                         = false
  enable_cross_zone_load_balancing = true

  # ----------------------------------------------------
  # NETWORK CONFIG
  # ----------------------------------------------------
  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [module.external-sg.security_group_id]

  # ----------------------------------------------------
  # HTTP TCP LISTENERS
  # ----------------------------------------------------
  http_tcp_listeners      = var.external_http_tcp_listeners
  http_tcp_listener_rules = var.external_http_tcp_listener_rules

  # ----------------------------------------------------
  # HTTPS_LISTENERS
  # ----------------------------------------------------
  https_listeners      = var.external_https_listeners
  https_listener_rules = var.external_https_listener_rules

  # ----------------------------------------------------
  # TARGETS
  # ----------------------------------------------------
  target_groups = var.external_target_groups

  # ----------------------------------------------------
  # LOGGING
  # ----------------------------------------------------
  access_logs = var.access_log_bucket != null ? {
    bucket  = var.access_log_bucket
    prefix  = "${var.project_name}-ext-alb"
    enabled = true
  } : {}

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  # desync_mitigation_mode = "defensive"
  # enable_cross_zone_load_balancing = false
  # enable_deletion_protection = false
  # enable_http2 = true
  # enable_waf_fail_open = false
  # extra_ssl_certs = []
  # idle_timeout = 60
  # ip_address_type = "ipv4"
  # lb_tags = {}
  # listener_ssl_policy_default = "ELBSecurityPolicy-2016-08"
  # load_balancer_create_timeout = "10m"
  # load_balancer_delete_timeout = "10m"
  # load_balancer_update_timeout = "10m"
  # name_prefix = null
  # putin_khuylo = true
  # subnet_mapping = [] *only for NLB
  # http_tcp_listeners_tags = {}
  # http_tcp_listener_rules_tags = {}
  # https_listeners_tags = {}
  # https_listener_rules_tags = {}
  # target_group_tags = {}
  # tags = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# INTERNAL APPLICATION LOAD BALANCER
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/8.1.0
#
# aws_lambda_permission: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
# aws_lb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# aws_lb_listener_certificate: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate
# aws_lb_listener_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# aws_lb_target_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# aws_lb_target_group_attachment: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
# ---------------------------------------------------------------------------------------------------------------------
module "internal-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  drop_invalid_header_fields = true

  create_lb = var.create_internal_alb

  name = "${var.project_name}-int-alb"

  load_balancer_type               = "application"
  internal                         = true
  enable_cross_zone_load_balancing = true

  # ----------------------------------------------------
  # NETWORK CONFIG
  #
  #   Internal ALB should exist in private subnets
  # ----------------------------------------------------
  vpc_id          = var.vpc_id
  subnets         = var.private_subnet_ids
  security_groups = [module.internal-sg.security_group_id]

  # ----------------------------------------------------
  # HTTP TCP LISTENERS
  # ----------------------------------------------------
  http_tcp_listeners      = var.internal_http_tcp_listeners
  http_tcp_listener_rules = var.internal_http_tcp_listener_rules

  # ----------------------------------------------------
  # HTTPS_LISTENERS
  # ----------------------------------------------------
  https_listeners      = var.internal_https_listeners
  https_listener_rules = var.internal_https_listener_rules

  # ----------------------------------------------------
  # TARGETS
  # ----------------------------------------------------
  target_groups = var.internal_target_groups

  # ----------------------------------------------------
  # LOGGING
  # ----------------------------------------------------
  access_logs = var.access_log_bucket != null ? {
    bucket  = var.access_log_bucket
    prefix  = "${var.project_name}-int-alb"
    enabled = true
  } : {}

  # ----------------------------------------------------
  # DEFAULTS
  # ----------------------------------------------------

  # desync_mitigation_mode = "defensive"
  # enable_cross_zone_load_balancing = false
  # enable_deletion_protection = false
  # enable_http2 = true
  # enable_waf_fail_open = false
  # extra_ssl_certs = []
  # idle_timeout = 60
  # ip_address_type = "ipv4"
  # lb_tags = {}
  # listener_ssl_policy_default = "ELBSecurityPolicy-2016-08"
  # load_balancer_create_timeout = "10m"
  # load_balancer_delete_timeout = "10m"
  # load_balancer_update_timeout = "10m"
  # name_prefix = null
  # putin_khuylo = true
  # subnet_mapping = [] *only for NLB
  # http_tcp_listeners_tags = {}
  # http_tcp_listener_rules_tags = {}
  # https_listeners_tags = {}
  # https_listener_rules_tags = {}
  # target_group_tags = {}
  # tags = {}
}
