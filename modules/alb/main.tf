terraform {
  required_version = "1.2.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  # dynamically sets external egress rules based on instance-sg being supplied
  external_sg_egress_with_source_security_group_id = !var.external_instance_sg_id ? var.external_sg_egress_with_source_security_group_id : [
    {
      source_security_group_id = var.external_instance_sg_id
      description              = "Allow all HTTP outbound traffic to instances on the instance listener and healthcheck port"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
    },
    {
      source_security_group_id = var.external_instance_sg_id
      description              = "Allow all HTTPS outbound traffic to instances on the instance listener and healthcheck port"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
    }
  ]
  external_sg_egress_with_cidr_blocks = var.external_instance_sg_id ? [] : var.external_sg_egress_with_cidr_blocks


  # dynamically sets internal ingress rules based on vpc_cidr being supplied
  internal_sg_ingress_with_cidr_blocks = !var.vpc_cidr ? var.internal_sg_ingress_with_cidr_blocks : [{
    cidr_blocks = var.vpc_cidr
    description = "Allow all inbound traffic from the VPC CIDR on the load balancer listener port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }]

  # dynamically sets internal egress rules based on internal_instance_sg_id being supplied
  internal_sg_egress_with_source_security_group_id = !var.internal_instance_sg_id ? var.internal_sg_egress_with_source_security_group_id : [
    {
      source_security_group_id = var.internal_instance_sg_id
      description              = "Allow all HTTP outbound traffic to instances on the instance listener and healthcheck port"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
    }
  ]
  internal_sg_egress_with_cidr_blocks = var.internal_instance_sg_id ? [] : var.internal_sg_egress_with_cidr_blocks
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EXTERNAL ALB SECURITY GROUP
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.13.0
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
  version = "4.13.0"

  create_sg = var.create_external_alb
  vpc_id    = var.vpc_id # required

  name        = "external-alb-sg-${var.name}" # required
  description = var.external_sg_description

  ingress_with_cidr_blocks              = var.external_sg_ingress_with_cidr_blocks
  ingress_with_source_security_group_id = var.external_sg_ingress_with_source_security_group_id

  egress_with_cidr_blocks              = local.external_sg_egress_with_cidr_blocks
  egress_with_source_security_group_id = local.external_sg_egress_with_source_security_group_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE INTERNAL ALB SECURITY GROUP
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.13.0
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
  version = "4.13.0"

  create_sg = var.create_internal_alb
  vpc_id    = var.vpc_id # required

  name        = "internal-alb-sg-${var.name}" # required
  description = var.internal_sg_description

  ingress_with_cidr_blocks              = local.internal_sg_ingress_with_cidr_blocks
  ingress_with_source_security_group_id = var.internal_sg_ingress_with_source_security_group_id

  egress_with_cidr_blocks              = local.internal_sg_egress_with_cidr_blocks
  egress_with_source_security_group_id = local.internal_sg_egress_with_source_security_group_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EXTERNAL APPLICATION LOAD BALANCER
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/8.1.0
#
# LB Listeners: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# LB Listener Rules: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# Targets: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# ---------------------------------------------------------------------------------------------------------------------

module "external-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  create_lb = var.create_external_alb

  name = "external-alb-${var.name}"

  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true

  # ----------------------------------------------------
  # NETWORK CONFIG
  #
  #   External ALB should exist in public subnets
  # ----------------------------------------------------
  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_arns
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
  access_logs = var.access_log_bucket != null ? { bucket = var.access_log_bucket } : {}

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
# CREATE INTERNAL APPLICATION LOAD BALANCER
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/8.1.0
#
# LB Listeners: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# LB Listener Rules: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# Targets: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# ---------------------------------------------------------------------------------------------------------------------

module "internal-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  create_lb = true

  name = "internal-alb-${var.name}"

  load_balancer_type               = "application"
  internal                         = true
  enable_cross_zone_load_balancing = true

  # ----------------------------------------------------
  # NETWORK CONFIG
  #
  #   Internal ALB should exist in private subnets
  # ----------------------------------------------------
  vpc_id          = var.vpc_id
  subnets         = var.private_subnet_arns
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
  access_logs = var.access_log_bucket != null ? { bucket = var.access_log_bucket } : {}

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
