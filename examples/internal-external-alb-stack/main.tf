terraform {
  required_version = "1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }

  backend "s3" {
    bucket = "competency-service-terraform-state"
    key    = "live/example/internal-external-alb-stack/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "competency-service-terraform-locks"
    encrypt        = true
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = "example-alb-vpc"
  azs  = ["us-east-1a", "us-east-1b"]
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  create_egress_only_igw = true
}

# still requires testing with ecs services, acm, and s3 logging

resource "aws_s3_bucket" "logs" {
  bucket = "example-log-bucket"
}

module "alb-stack" {
  source = "../../modules/alb"

  name   = "alb-stack-example"
  region = "us-east-1"

  # Network config
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr_block
  private_subnet_arns = module.vpc.private_subnet_arns
  public_subnet_arns  = module.vpc.public_subnet_arns

  # Using default Security Groups

  # External ALB config
  external_http_tcp_listeners = [
    { # permanently redirect HTTP to HTTPS
      port        = 80
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_codr = "HTTP_301"
      }
    }
  ]
  external_http_tcp_listener_rules = []

  external_https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "" # needs cert
      target_group_index = 0  # should fwd to api-gateway
    }
  ]
  external_https_listener_rules = []

  external_target_groups = [
    { # instance target (ECS service will register target group association)
      name             = "Api-Gateway"
      backend_port     = 80
      backend_protocol = "HTTP"
      protocol_version = "HTTP2"
      health_check = {
        matcher = "200-299"
        path    = "/"
      }
    }
  ]

  # Internal ALB config
  internal_http_tcp_listeners = [
    { # Internal ALB is referenced from service in public subnets (i.e API-Gateway)
      port = 80
    }
  ]

  internal_http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 0 # micro-service 1
      }]
      conditions = [{
        path_patterns = ["/service1"]
      }]
    },
    {
      http_tcp_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 1 # micro-service 2
      }]
      conditions = [{
        path_patterns = ["/service2"]
      }]
    }
  ]

  internal_target_groups = [
    {
      name             = "Service 1 Target Group"
      backend_port     = 80
      backend_protocol = "HTTP"
      protocol_version = "HTTP2"
      health_check = {
        matcher = "200-299"
        path    = "/"
      }
    },
    {
      name             = "Service 2 Target Group"
      backend_port     = 80
      backend_protocol = "HTTP"
      protocol_version = "HTTP2"
      target_type      = "instance"
      health_check = {
        matcher = "200-299"
        path    = "/"
      }
    }
  ]
  access_log_bucket = "example-log-bucket"
}