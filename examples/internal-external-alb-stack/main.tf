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
  external_target_groups = []

  external_http_tcp_listeners      = []
  external_http_tcp_listener_rules = []

  external_https_listeners      = []
  external_https_listener_rules = []

  external_access_logs = {}

  # Internal ALB config
  internal_target_groups = []

  internal_http_tcp_listeners      = []
  internal_http_tcp_listener_rules = []

  internal_https_listeners      = []
  internal_https_listener_rules = []

  internal_access_logs = {}
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