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

  access_logs {
    bucket  = aws_s3_bucket.access_logs.bucket
    enabled = var.enable_access_logs
  }

  depends_on = [
    aws_s3_bucket.access_logs
  ]
}


# -------------------------------------------
# CREATE ALB HTTP LISTENER
# -------------------------------------------

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

  certificate_arn = data.aws_acm_certificate.cert.arn
  ssl_policy      = ""

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

# resource "aws_security_group" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE S3 BUCKET

# FOR ALB ACCESS LOGS.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE S3 BUCKET FOR ALB ACCESS LOGS
# -------------------------------------------

# resource "aws_s3_bucket" "access_logs" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE ALB DNS RECORD.

# ------------------------------------------------------------


# -------------------------------------------
# CREATE ALB DNS RECORD
# -------------------------------------------

# the following can be used to get the host zone id
# data "aws_route53_zone" "zone" {}

# the following should be created always
# resource "aws_route53_record" "alb" {}
