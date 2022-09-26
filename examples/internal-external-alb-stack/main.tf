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

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb-sg"
  description = "Security group for example usage with ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "internal-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.1.0"

  create_lb = true

  name = "example-internal-alb"

  load_balancer_type               = "application"
  internal                         = true
  enable_cross_zone_load_balancing = true

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnet_arns
  security_groups = [module.sg.security_group_id]

  # listeners
  http_tcp_listeners = [
    {
      target_group_index = 0

      protocol = "HTTP"
      port     = 80
    }
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 0
      }]
      conditions = [{
        path_patterns = ["/service1"]
      }]
    },
    {
      http_tcp_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 1
      }]
      conditions = [{
        path_patterns = ["/service2"]
      }]
    }
  ]

  # targets

  target_groups = [
    {
      name = "Service 1 Target Group"

      backend_protocol = 80
      backend_protocol = "HTTP"
      protocol_version = "HTTP2"
      target_type      = "instance"

      # deregistration_delay = 300 (default) should be longer then StopTimeout in task-defintion and Client Connection Timeout

      health_check = {
        matcher = "200-299"
        path    = "/"
      }
    },
    {
      name = "Service 2 Target Group"

      backend_protocol = 80
      backend_protocol = "HTTP"
      protocol_version = "HTTP2"
      target_type      = "instance"

      # deregistration_delay = 300 (default) should be longer then StopTimeout in task-defintion and Client Connection Timeout

      health_check = {
        matcher = "200-299"
        path    = "/"
      }
    }
  ]
}