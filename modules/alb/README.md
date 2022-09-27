<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (1.2.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (4.29.0)

## Providers

No providers.

## Modules

The following Modules are called:

### <a name="module_external-alb"></a> [external-alb](#module\_external-alb)

Source: terraform-aws-modules/alb/aws

Version: 8.1.0

### <a name="module_external-sg"></a> [external-sg](#module\_external-sg)

Source: terraform-aws-modules/security-group/aws

Version: 4.13.0

### <a name="module_internal-alb"></a> [internal-alb](#module\_internal-alb)

Source: terraform-aws-modules/alb/aws

Version: 8.1.0

### <a name="module_internal-sg"></a> [internal-sg](#module\_internal-sg)

Source: terraform-aws-modules/security-group/aws

Version: 4.13.0

## Resources

No resources.

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the project the resources are associated with

Type: `string`

### <a name="input_private_subnet_arns"></a> [private\_subnet\_arns](#input\_private\_subnet\_arns)

Description: List of private subnet ARNs to deploy internal ALB into (required if create\_internal\_alb == true)

Type: `list(string)`

### <a name="input_public_subnet_arns"></a> [public\_subnet\_arns](#input\_public\_subnet\_arns)

Description: List of public subnet ARNs to deploy external ALB into (required if create\_external\_alb == true)

Type: `list(string)`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_external_alb"></a> [create\_external\_alb](#input\_create\_external\_alb)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_create_internal_alb"></a> [create\_internal\_alb](#input\_create\_internal\_alb)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_external_access_logs"></a> [external\_access\_logs](#input\_external\_access\_logs)

Description: Map containing access logging configuration for load balancer.

Type:

```hcl
optional(object({
    enabled = optional(bool) # default true
    bucket  = string         # bucket must exist
    prefix  = optional(string)
  }))
```

Default: `{}`

### <a name="input_external_http_tcp_listener_rules"></a> [external\_http\_tcp\_listener\_rules](#input\_external\_http\_tcp\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_external_http_tcp_listeners"></a> [external\_http\_tcp\_listeners](#input\_external\_http\_tcp\_listeners)

Description: A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_external_https_listener_rules"></a> [external\_https\_listener\_rules](#input\_external\_https\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_external_https_listeners"></a> [external\_https\_listeners](#input\_external\_https\_listeners)

Description: A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_external_instance_sg_id"></a> [external\_instance\_sg\_id](#input\_external\_instance\_sg\_id)

Description: The security group id of the external target instance

Type: `string`

Default: `null`

### <a name="input_external_sg_description"></a> [external\_sg\_description](#input\_external\_sg\_description)

Description: n/a

Type: `string`

Default: `"Security group attached to external alb managed by terraform"`

### <a name="input_external_sg_egress_with_cidr_blocks"></a> [external\_sg\_egress\_with\_cidr\_blocks](#input\_external\_sg\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used (set to [] if using external\_sg\_egress\_with\_source\_security\_group\_id, see main.tf locals)

Type:

```hcl
list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
```

Default:

```json
[
  {
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all HTTP outbound traffic to instances on the instance listener and healthcheck port",
    "from_port": 80,
    "protocol": "tcp",
    "to_port": 80
  },
  {
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all HTTPS outbound traffic to instances on the instance listener and healthcheck port",
    "from_port": 443,
    "protocol": "tcp",
    "to_port": 443
  }
]
```

### <a name="input_external_sg_egress_with_source_security_group_id"></a> [external\_sg\_egress\_with\_source\_security\_group\_id](#input\_external\_sg\_egress\_with\_source\_security\_group\_id)

Description: List of egress rules to create where 'source\_security\_group\_id' is used (external\_sg\_egress\_with\_cidr\_blocks set to [] if using this variable, see main.tf locals)

Type:

```hcl
list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
```

Default: `[]`

### <a name="input_external_sg_ingress_with_cidr_blocks"></a> [external\_sg\_ingress\_with\_cidr\_blocks](#input\_external\_sg\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used

Type:

```hcl
list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
```

Default:

```json
[
  {
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all HTTP inbound traffic on the load balancer listener port",
    "from_port": 80,
    "protocol": "tcp",
    "to_port": 80
  },
  {
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all HTTPS inbound traffic on the load balancer listener port",
    "from_port": 443,
    "protocol": "tcp",
    "to_port": 443
  }
]
```

### <a name="input_external_sg_ingress_with_source_security_group_id"></a> [external\_sg\_ingress\_with\_source\_security\_group\_id](#input\_external\_sg\_ingress\_with\_source\_security\_group\_id)

Description: List of ingress rules to create where 'source\_security\_group\_id' is used

Type:

```hcl
list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
```

Default: `[]`

### <a name="input_external_target_groups"></a> [external\_target\_groups](#input\_external\_target\_groups)

Description: A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_internal_access_logs"></a> [internal\_access\_logs](#input\_internal\_access\_logs)

Description: Map containing access logging configuration for load balancer.

Type:

```hcl
optional(object({
    enabled = optional(bool) # default true
    bucket  = string         # bucket must exist
    prefix  = optional(string)
  }))
```

Default: `{}`

### <a name="input_internal_http_tcp_listener_rules"></a> [internal\_http\_tcp\_listener\_rules](#input\_internal\_http\_tcp\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_internal_http_tcp_listeners"></a> [internal\_http\_tcp\_listeners](#input\_internal\_http\_tcp\_listeners)

Description: A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_internal_https_listener_rules"></a> [internal\_https\_listener\_rules](#input\_internal\_https\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_internal_https_listeners"></a> [internal\_https\_listeners](#input\_internal\_https\_listeners)

Description: A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index])

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_internal_instance_sg_id"></a> [internal\_instance\_sg\_id](#input\_internal\_instance\_sg\_id)

Description: The security group id of the internal target instance

Type: `string`

Default: `null`

### <a name="input_internal_sg_description"></a> [internal\_sg\_description](#input\_internal\_sg\_description)

Description: n/a

Type: `string`

Default: `"Security group attached to internal alb managed by terraform"`

### <a name="input_internal_sg_egress_with_cidr_blocks"></a> [internal\_sg\_egress\_with\_cidr\_blocks](#input\_internal\_sg\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used (set to [] if using internal\_sg\_egress\_with\_source\_security\_group\_id, see main.tf locals)

Type:

```hcl
list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
```

Default:

```json
[
  {
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all HTTP outbound traffic to instances on the instance listener and healthcheck port",
    "from_port": 80,
    "protocol": "tcp",
    "to_port": 80
  }
]
```

### <a name="input_internal_sg_egress_with_source_security_group_id"></a> [internal\_sg\_egress\_with\_source\_security\_group\_id](#input\_internal\_sg\_egress\_with\_source\_security\_group\_id)

Description: List of egress rules to create where 'source\_security\_group\_id' is used (internal\_sg\_egress\_with\_cidr\_blocks set to [] if using this variable, see main.tf locals)

Type:

```hcl
list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
```

Default: `[]`

### <a name="input_internal_sg_ingress_with_cidr_blocks"></a> [internal\_sg\_ingress\_with\_cidr\_blocks](#input\_internal\_sg\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used (if vpc\_cidr is set, default rules set with cidr\_blocks, see main.tf locals)

Type:

```hcl
list(object({
    cidr_blocks = string
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
```

Default:

```json
[
  {
    "cidr_blocks": "0.0.0.0/0",
    "description": "Allow all HTTP inbound traffic on the load balancer listener port",
    "from_port": 80,
    "protocol": "tcp",
    "to_port": 80
  }
]
```

### <a name="input_internal_sg_ingress_with_source_security_group_id"></a> [internal\_sg\_ingress\_with\_source\_security\_group\_id](#input\_internal\_sg\_ingress\_with\_source\_security\_group\_id)

Description: List of ingress rules to create where 'source\_security\_group\_id' is used

Type:

```hcl
list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
```

Default: `[]`

### <a name="input_internal_target_groups"></a> [internal\_target\_groups](#input\_internal\_target\_groups)

Description: A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_region"></a> [region](#input\_region)

Description: n/a

Type: `string`

Default: `"us-east-1"`

### <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr)

Description: The VPC CIDR block of variable.vpc\_id

Type: `string`

Default: `null`

## Outputs

No outputs.
<!-- END_TF_DOCS -->