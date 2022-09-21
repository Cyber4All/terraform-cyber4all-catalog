provider "aws" {
  region = "us-east-1"
}

locals {
  domain_name = "terraform-aws-modules.modules.tf"
}

##################################################################
# Data sources to get VPC and subnets
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb-sg-${random_pet.this.id}"
  description = "Security group for example usage with ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

##################################################################
# Application loadbalancer configuration
##################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  create_lb = true

  /* desync_mitigation_mode = "defensive" */
  enable_cross_zone_load_balancing = true
  /* enable_http2 = true */
  
  http_tcp_listener_rules = [] # need to implement still
  http_tcp_listeners = [] # need to implement still

  http_listener_rules = []
  http_listeners = []

  internal = false

  ip_address_type = "ipv4"

  # https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
  /* listener_ssl_policy_default = "ELBSecurityPolicy-2016-08" */

  load_balancer_type = "application"

  name = "example-external-alb"

  security_groups = []
  subnets = []

  target_groups =  []

  vpc_id = ""

}
