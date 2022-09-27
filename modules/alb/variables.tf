# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Name of the project the resources are associated with"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_arns" {
  description = "List of public subnet ARNs to deploy external ALB into (required if create_external_alb == true)"
  type        = list(string)
}

variable "private_subnet_arns" {
  description = "List of private subnet ARNs to deploy internal ALB into (required if create_internal_alb == true)"
  type        = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "external_instance_sg_id" {
  description = "The security group id of the external target instance"
  type        = string
  default     = null
}

variable "internal_instance_sg_id" {
  description = "The security group id of the internal target instance"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "The VPC CIDR block of variable.vpc_id"
  type        = string
  default     = null
}

# ----------------------------------------------------
# external security group parameters
# ----------------------------------------------------

variable "external_sg_description" {
  type    = string
  default = "Security group attached to external alb managed by terraform"
}

# ingress rules
variable "external_sg_ingress_with_cidr_blocks" {
  description = "List of ingress rules to create where 'cidr_blocks' is used"
  type = list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all HTTP inbound traffic on the load balancer listener port"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    },
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all HTTPS inbound traffic on the load balancer listener port"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  ]
}

variable "external_sg_ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used"
  type = list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
  default = []
}

# egress rules
variable "external_sg_egress_with_cidr_blocks" {
  description = "List of egress rules to create where 'cidr_blocks' is used (set to [] if using external_sg_egress_with_source_security_group_id, see main.tf locals)"
  type = list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all HTTP outbound traffic to instances on the instance listener and healthcheck port"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    },
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all HTTPS outbound traffic to instances on the instance listener and healthcheck port"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  ]
}

variable "external_sg_egress_with_source_security_group_id" {
  description = "List of egress rules to create where 'source_security_group_id' is used (external_sg_egress_with_cidr_blocks set to [] if using this variable, see main.tf locals)"
  type = list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
  default = []
}

# ----------------------------------------------------
# internal security group parameters
# ----------------------------------------------------

variable "internal_sg_description" {
  type    = string
  default = "Security group attached to internal alb managed by terraform"
}

# ingress rules
variable "internal_sg_ingress_with_cidr_blocks" {
  description = "List of ingress rules to create where 'cidr_blocks' is used (if vpc_cidr is set, default rules set with cidr_blocks, see main.tf locals)"
  type = list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all HTTP inbound traffic on the load balancer listener port"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    }
  ]
}

variable "internal_sg_ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used"
  type = list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
  default = []
}

# egress rules
variable "internal_sg_egress_with_cidr_blocks" {
  description = "List of egress rules to create where 'cidr_blocks' is used (set to [] if using internal_sg_egress_with_source_security_group_id, see main.tf locals)"
  type = list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all HTTP outbound traffic to instances on the instance listener and healthcheck port"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    }
  ]
}

variable "internal_sg_egress_with_source_security_group_id" {
  description = "List of egress rules to create where 'source_security_group_id' is used (internal_sg_egress_with_cidr_blocks set to [] if using this variable, see main.tf locals)"
  type = list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
  default = []
}

# ----------------------------------------------------
# external application load balancer parameters
# ----------------------------------------------------

variable "create_external_alb" {
  type    = bool
  default = true
}

variable "external_http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  type = list(object({
    port     = optional(port)
    protocol = optional(string) # HTTP | HTTPS, default HTTP

    action_type        = optional(string) # forward | redirect | fixed-response, default forward
    target_group_index = optional(number) # default [count.index]

    redirect = optional(object({
      path        = optional(string) # default /#{path}
      host        = optional(string) # default #{host}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = string           # HTTP_301 | HTTP_302
    }))

    fixed_response = optional(object({
      content_type = string # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX
    }))
  }))
  default = []
}

variable "external_http_tcp_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index])"
  type = list(object({
    http_tcp_listener_index = number
    priority                = number

    actions = list(object({
      type = string # redirect | fixed-response | forward | weighted-forward

      # redirect options
      host        = optional(string) # default #{host}
      path        = optional(string) # default /#{path}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = optional(string) # HTTP_301 | HTTP_302

      # fixed-response options
      content_type = optional(string) # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX

      # forward options
      target_group_index = optional(number) # default [count.index]

      # weighted-forward options
      target_groups = optional(list(object({
        target_group_index = optional(number)
        weight             = optional(number)
      })))
      stickiness = optional(object({
        enabled  = optional(bool)   # default false
        duration = optional(number) # default 1
      }))
    }))

    conditions = list(object({
      host_headers = optional(list(string))

      http_headers = optional(list(object({
        http_header_name = string
        values           = string
      })))

      http_request_methods = optional(list(string))

      query_strings = optional(list(object({
        key   = optional(string)
        value = string
      })))

      source_ips = optional(list(string))
    }))
  }))
  default = []
}

variable "external_https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])"
  type = list(object({
    port            = optional(port)
    protocol        = optional(string) # HTTP | HTTPS, default HTTPS
    certificate_arn = string
    ssl_policy      = optional(string)
    alpn_policy     = optional(string)

    action_type        = optional(string) # forward | redirect | fixed-response | authenticate-cognito | authenticate-oidc
    target_group_index = optional(number) # default [count.index] 

    fixed_response = optional(object({
      content_type = string # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX
    }))

    redirect = optional(object({
      host        = optional(string) # default #{host}
      path        = optional(string) # default /#{path}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = optional(string) # HTTP_301 | HTTP_302
    }))

    # authenticate-cognito options not supported
    # authenticate-oidc options not supported
  }))
  default = []
}

variable "external_https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
  type = list(object({
    https_listener_index = optional(number) # default [count.index]
    priority             = optional(number)

    actions = optional(list(object({
      type = string # redirect | fixed-response | forward | weighted-forward | authenticate-oidc | authenticate-cognito

      # redirect options
      host        = optional(string) # default #{host}
      path        = optional(string) # default /#{path}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = optional(string) # HTTP_301 | HTTP_302

      # fixed-response options
      content_type = optional(string) # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX

      # forward options
      target_group_index = optional(number) # default [count.index]

      # weighted-forward options
      target_groups = optional(list(object({
        target_group_index = optional(number)
        weight             = optional(number)
      })))
      stickiness = optional(object({
        enabled  = optional(bool)   # default false
        duration = optional(number) # default 1
      }))

      # authenticate-cognito options not supported
      # authenticate-oidc options not supported
    })))
  }))
  default = []
}

variable "external_target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  type = list(object({
    name             = string
    backend_protocol = number # GENEVE | HTTP | HTTPS | TCP | TCP_UDP | TLS | UDP
    backend_port     = number
    protocol_version = optional(string) # HTTP2 | HTTP1, default HTTP1
    target_type      = optional(string) # default instance

    connection_termination             = optional(bool)   # default false
    deregistration_delay               = optional(number) # default 300 seconds
    slow_start                         = optional(number) # default 0 seconds
    proxy_protocol_v2                  = optional(bool)   # default false
    lambda_multi_value_headers_enabled = optional(bool)   # default false
    load_balancing_algorithm_type      = optional(string) # default round_robin
    preserve_client_ip                 = optional(bool)
    ip_address_type                    = optional(string) # ipv4 | ipv6

    health_check = optional(object({
      enabled             = optional(bool)   # default true
      interval            = optional(number) # default 30 seconds
      path                = optional(string)
      port                = optional(string) # default traffic-port
      healthy_threshold   = optional(number) # default 3
      unhealthy_threshold = optional(number) # default 3
      timeout             = optional(number) # default 5 or 10 seconds
      protocol            = optional(string) # default HTTP
      matcher             = optional(string)
    }))

    stickiness = optional(object({
      enabled         = optional(bool)   # default true
      cookie_duration = optional(number) # default 86400 (1 day)
      type            = string           # lb_cookie | app_cookie | source_ip
      cookie_name     = optional(string)
    }))

  }))
  default = []
}

variable "external_access_logs" {
  description = "Map containing access logging configuration for load balancer."
  type = optional(object({
    enabled = optional(bool) # default true
    bucket  = string         # bucket must exist
    prefix  = optional(string)
  }))
  default = {}
}

# ----------------------------------------------------
# internal application load balancer parameters
# ----------------------------------------------------

variable "create_internal_alb" {
  type    = bool
  default = true
}

variable "internal_http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  type = list(object({
    port     = optional(port)
    protocol = optional(string) # HTTP | HTTPS, default HTTP

    action_type        = optional(string) # forward | redirect | fixed-response, default forward
    target_group_index = optional(number) # default [count.index]

    redirect = optional(object({
      path        = optional(string) # default /#{path}
      host        = optional(string) # default #{host}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = string           # HTTP_301 | HTTP_302
    }))

    fixed_response = optional(object({
      content_type = string # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX
    }))
  }))
  default = []
}

variable "internal_http_tcp_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index])"
  type = list(object({
    http_tcp_listener_index = number
    priority                = number

    actions = list(object({
      type = string # redirect | fixed-response | forward | weighted-forward

      # redirect options
      host        = optional(string) # default #{host}
      path        = optional(string) # default /#{path}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = optional(string) # HTTP_301 | HTTP_302

      # fixed-response options
      content_type = optional(string) # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX

      # forward options
      target_group_index = optional(number) # default [count.index]

      # weighted-forward options
      target_groups = optional(list(object({
        target_group_index = optional(number)
        weight             = optional(number)
      })))
      stickiness = optional(object({
        enabled  = optional(bool)   # default false
        duration = optional(number) # default 1
      }))
    }))

    conditions = list(object({
      host_headers = optional(list(string))

      http_headers = optional(list(object({
        http_header_name = string
        values           = string
      })))

      http_request_methods = optional(list(string))

      query_strings = optional(list(object({
        key   = optional(string)
        value = string
      })))

      source_ips = optional(list(string))
    }))
  }))
  default = []
}

variable "internal_https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])"
  type = list(object({
    port            = optional(port)
    protocol        = optional(string) # HTTP | HTTPS, default HTTPS
    certificate_arn = string
    ssl_policy      = optional(string)
    alpn_policy     = optional(string)

    action_type        = optional(string) # forward | redirect | fixed-response | authenticate-cognito | authenticate-oidc
    target_group_index = optional(number) # default [count.index] 

    fixed_response = optional(object({
      content_type = string # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX
    }))

    redirect = optional(object({
      host        = optional(string) # default #{host}
      path        = optional(string) # default /#{path}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = optional(string) # HTTP_301 | HTTP_302
    }))

    # authenticate-cognito options not supported
    # authenticate-oidc options not supported
  }))
  default = []
}

variable "internal_https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
  type = list(object({
    https_listener_index = optional(number) # default [count.index]
    priority             = optional(number)

    actions = optional(list(object({
      type = string # redirect | fixed-response | forward | weighted-forward | authenticate-oidc | authenticate-cognito

      # redirect options
      host        = optional(string) # default #{host}
      path        = optional(string) # default /#{path}
      port        = optional(number) # 1 - 65535 | #{port}, default #{port}
      protocol    = optional(string) # HTTP | HTTPS | #{protocol}, default #{protocol}
      query       = optional(string) # default #{query}
      status_code = optional(string) # HTTP_301 | HTTP_302

      # fixed-response options
      content_type = optional(string) # text/plain | text/css | text/html | application/javascript | application/json
      message_body = optional(string)
      status_code  = optional(number) # 2XX, 4XX, 5XX

      # forward options
      target_group_index = optional(number) # default [count.index]

      # weighted-forward options
      target_groups = optional(list(object({
        target_group_index = optional(number)
        weight             = optional(number)
      })))
      stickiness = optional(object({
        enabled  = optional(bool)   # default false
        duration = optional(number) # default 1
      }))

      # authenticate-cognito options not supported
      # authenticate-oidc options not supported
    })))
  }))
  default = []
}

variable "internal_target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  type = list(object({
    name             = string
    backend_protocol = number # GENEVE | HTTP | HTTPS | TCP | TCP_UDP | TLS | UDP
    backend_port     = number
    protocol_version = optional(string) # HTTP2 | HTTP1, default HTTP1
    target_type      = optional(string) # default instance

    connection_termination             = optional(bool)   # default false
    deregistration_delay               = optional(number) # default 300 seconds
    slow_start                         = optional(number) # default 0 seconds
    proxy_protocol_v2                  = optional(bool)   # default false
    lambda_multi_value_headers_enabled = optional(bool)   # default false
    load_balancing_algorithm_type      = optional(string) # default round_robin
    preserve_client_ip                 = optional(bool)
    ip_address_type                    = optional(string) # ipv4 | ipv6

    health_check = optional(object({
      enabled             = optional(bool)   # default true
      interval            = optional(number) # default 30 seconds
      path                = optional(string)
      port                = optional(string) # default traffic-port
      healthy_threshold   = optional(number) # default 3
      unhealthy_threshold = optional(number) # default 3
      timeout             = optional(number) # default 5 or 10 seconds
      protocol            = optional(string) # default HTTP
      matcher             = optional(string)
    }))

    stickiness = optional(object({
      enabled         = optional(bool)   # default true
      cookie_duration = optional(number) # default 86400 (1 day)
      type            = string           # lb_cookie | app_cookie | source_ip
      cookie_name     = optional(string)
    }))

  }))
  default = []
}

variable "internal_access_logs" {
  description = "Map containing access logging configuration for load balancer."
  type = optional(object({
    enabled = optional(bool) # default true
    bucket  = string         # bucket must exist
    prefix  = optional(string)
  }))
  default = {}
}
