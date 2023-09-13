terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  domain_name = "example.com${var.random_id}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "alb-test${var.random_id}"
  cidr = "10.0.0.0/16"

  azs            = [for letter in ["a", "b", "c"] : "${var.region}${letter}"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}


# --------------------------------------------------------------------
# SET UP A ROUTE53 ZONE AND ACM CERTIFICATE FOR THE ALB TEST
#
# THIS IS NOT REAL! YOU WOULD GET THE ACM CERTIFICATE FROM A REAL
# PUBLIC DOMAIN THAT WE OWN. THIS USES A PRIVATE DOMAIN.
# --------------------------------------------------------------------

resource "aws_route53_zone" "dns" {
  name = local.domain_name

  force_destroy = true

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_acm_certificate" "dns" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dns" {
  for_each = {
    for dvo in aws_acm_certificate.dns.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.dns.zone_id
}

resource "aws_acm_certificate_validation" "dns" {
  certificate_arn         = aws_acm_certificate.dns.arn
  validation_record_fqdns = [for record in aws_route53_record.dns : record.fqdn]
}


# --------------------------------------------------------------------
# CREATE THE ALB MODULE
# --------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  alb_name = "alb-test${var.random_id}"

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.public_subnets

  enable_access_logs = true

  hosted_zone_name = local.domain_name
}
