provider "aws" {
  region = "us-east-1"
}

/* locals {
  domain_name = "terraform-aws-modules.modules.tf"
} */

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

  name        = "alb-sg"
  description = "Security group for example usage with ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

##################################################################
# Gets ACM information for HTTPS (x.509 Cert information)
##################################################################

/* data "aws_route53_zone" "this" {
  name = local.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = local.domain_name # trimsuffix(data.aws_route53_zone.this.name, ".")
  zone_id     = data.aws_route53_zone.this.id
} */

##################################################################
# Application loadbalancer configuration
##################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  create_lb = true

  name = "example-external-alb"

  # load_balancer_type = "application"
  # internal = false
  enable_cross_zone_load_balancing = true

  vpc_id = data.aws_vpc.default.id
  subnets = data.aws_subnets.all.ids
  security_groups = [module.security_group.security_group_id]

  
  # listeners
  http_tcp_listeners = [
    {
      port = 80
      protocol = "HTTP"
      target_group_index = 0 # used to identify in the http_tcp_listeners_rules
    },
    /* {
      port        = 81
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    {
      port        = 82
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    }, */
  ]
  
  /* https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 1
    }
  ] */

  # listener rules
  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 5000
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "www.youtube.com"
        path        = "/watch"
        query       = "v=dQw4w9WgXcQ"
        protocol    = "HTTP"
      }]

      conditions = [{
        query_strings = [{
          key   = "video"
          value = "random"
        }]
      }]
    }, 
  ]
  /*
  https_listener_rules = []
  */
  target_groups =  [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      targets = {
        my_ec2 = {
          target_id = aws_instance.this.id
          port      = 80
        },
        my_ec2_again = {
          target_id = aws_instance.this.id
          port      = 8080
        }
      }
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    },
  ] 

  # https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
  /* listener_ssl_policy_default = "ELBSecurityPolicy-2016-08" */

}


##################
# Extra resources
##################
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
}
