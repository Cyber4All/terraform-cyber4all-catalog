# -------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER (ALB)
# 
# This module will create an ALB that can be used to route traffic to ECS services.
#
# The module initializes an HTTP/HTTPS listener on the ALB. For non-production
# deployments, the HTTP listener can route traffic to the targets directly. For
# production deployments, the HTTP listener will redirect traffic to the HTTPS.
# 
# A DNS record is created for the ALB. This DNS record can be used to route traffic
# to the ALB.
#
# ECS services can be be linked to the ALB by using a listener rule. The listener
# rule will route traffic to the ECS service based on the target group (which is
# also configured in the ECS service module).
#
# The module includes the following:
#
# - ALB
# - ALB Security Group
# - ALB HTTP Listener
# - ALB HTTPS Listener
# - ALB DNS Record
#
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE ALB,

# DEFAULT LISTENERS (HTTP or HTTP/HTTPS), AND SECURITY GROUP.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE THE ALB
# -------------------------------------------

resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.vpc_subnet_ids

  drop_invalid_header_fields = true
  ip_address_type            = "ipv4"

}


# -------------------------------------------
# CREATE ALB HTTP LISTENER
# -------------------------------------------

# This is ignored because the implementation was
# intentional. enable_https_listener should only
# be set to false in non-production environments.
# tfsec:ignore:aws-elb-http-not-used
resource "aws_lb_listener" "http" {
  # creates the http listener when https is disabled
  count = var.enable_https_listener ? 0 : 1

  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}


# -------------------------------------------
# CREATE ALB HTTPS LISTENERS
# -------------------------------------------

data "aws_acm_certificate" "cert" {
  # will only fetch a certificate if https is enabled
  count = var.enable_https_listener ? 1 : 0

  domain      = var.hosted_zone_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "redirect" {
  # creates the http redirect listener when https is enabled
  count = var.enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [
    data.aws_acm_certificate.cert
  ]
}

resource "aws_lb_listener" "https" {
  # creates the https listener when https is enabled
  count = var.enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"

  certificate_arn = data.aws_acm_certificate.cert[0].arn
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }

  depends_on = [
    data.aws_acm_certificate.cert
  ]
}


# -------------------------------------------
# CREATE ALB SECURITY GROUP
# -------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.alb_name}-lb-sg"
  description = "Terraform managed security group for ${var.alb_name} ALB."

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic to the ALB from anywhere."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  count = var.enable_https_listener ? 1 : 0

  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic to the ALB from anywhere."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE ALB DNS RECORD.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE ALB DNS RECORD
# -------------------------------------------

data "aws_route53_zone" "zone" {
  count = var.hosted_zone_name != "" ? 1 : 0

  name = var.hosted_zone_name
}

resource "aws_route53_record" "alb" {
  count = var.hosted_zone_name != "" ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].id
  name    = "${var.dns_record_prefix}.${var.hosted_zone_name}"
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
