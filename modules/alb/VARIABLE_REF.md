# ALB Variable Reference

## Security Groups

### Ingress/Egress With CIDR Blocks

```hcl
[
    {
        cidr_blocks = string
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
    }
]
```

### Ingress/Egress With Source Security Group ID

```hcl
[
    {
        source_security_group_id = string
        description              = string
        from_port                = number
        to_port                  = number
        protocol                 = string
    }
]
```

## Application Load Balancer

### HTTP TCP Listeners

```hcl
[
    {
        port     = number
        protocol = string # HTTP | HTTPS, default HTTP

        action_type        = string # forward | redirect | fixed-response, default forward
        target_group_index = number # default [count.index]

        redirect = {
            path        = string # default /#{path}
            host        = string # default #{host}
            port        = number # 1 - 65535 | #{port}, default #{port}
            protocol    = string # HTTP | HTTPS | #{protocol}, default #{protocol}
            query       = string # default #{query}
            status_code = string           # HTTP_301 | HTTP_302
        }

        fixed_response = {
            content_type = string # text/plain | text/css | text/html | application/javascript | application/json
            message_body = string
            status_code  = number # 2XX, 4XX, 5XX
        }
    }
]
```

### HTTP TCP Listener Rules

```hcl
[
    {
        http_tcp_listener_index = number
        priority                = number

        actions = {
            type = string # redirect | fixed-response | forward | weighted-forward

            # redirect options
            host        = string # default #{host}
            path        = string # default /#{path}
            port        = number # 1 - 65535 | #{port}, default #{port}
            protocol    = string # HTTP | HTTPS | #{protocol}, default #{protocol}
            query       = string # default #{query}
            status_code = string # HTTP_301 | HTTP_302

            # fixed-response options
            content_type = string # text/plain | text/css | text/html | application/javascript | application/json
            message_body = string
            status_code  = number # 2XX, 4XX, 5XX

            # forward options
            target_group_index = number # default [count.index]

            # weighted-forward options
            target_groups = {
                target_group_index = number
                weight             = number
            }

            stickiness = {
                enabled  = bool   # default false
                duration = number # default 1
            }
        }

        conditions = {
            host_headers = [string]

            http_headers = [
                {
                    http_header_name = string
                    values           = string
                }
            ]

            http_request_methods = [string]

            query_strings = {
                key   = string
                value = string
            }

            source_ips = [string]
        }
    }
]
```

### HTTPS Listeners

```hcl
[
    {
        port            = number
        protocol        = string # HTTP | HTTPS, default HTTPS
        certificate_arn = string
        ssl_policy      = string
        alpn_policy     = string

        action_type        = string # forward | redirect | fixed-response | authenticate-cognito | authenticate-oidc
        target_group_index = number # default [count.index] 

        fixed_response = {
            content_type = string # text/plain | text/css | text/html | application/javascript | application/json
            message_body = string
            status_code  = number # 2XX, 4XX, 5XX
        }

        redirect = {
            host        = string # default #{host}
            path        = string # default /#{path}
            port        = number # 1 - 65535 | #{port}, default #{port}
            protocol    = string # HTTP | HTTPS | #{protocol}, default #{protocol}
            query       = string # default #{query}
            status_code = string # HTTP_301 | HTTP_302
        }

        # authenticate-cognito options not supported
        # authenticate-oidc options not supported
    }
]
```

### HTTPS Listener Rules

```hcl
[
    {
        https_listener_index = number # default [count.index]
        priority             = number

        actions = [
            {
                type = string # redirect | fixed-response | forward | weighted-forward | authenticate-oidc | authenticate-cognito

                # redirect options
                host        = string # default #{host}
                path        = string # default /#{path}
                port        = number # 1 - 65535 | #{port}, default #{port}
                protocol    = string # HTTP | HTTPS | #{protocol}, default #{protocol}
                query       = string # default #{query}
                status_code = string # HTTP_301 | HTTP_302

                # fixed-response options
                content_type = string # text/plain | text/css | text/html | application/javascript | application/json
                message_body = string
                status_code  = number # 2XX, 4XX, 5XX

                # forward options
                target_group_index = number # default [count.index]

                # weighted-forward options
                target_groups = [
                    {
                        target_group_index = number
                        weight             = number
                    }
                ]
                stickiness = {
                    enabled  = bool   # default false
                    duration = number # default 1
                }

                # authenticate-cognito options not supported
                # authenticate-oidc options not supported
            }
        ]
    }
]
```

### Target Groups

```hcl
[
    {
        name             = string
        backend_protocol = number # GENEVE | HTTP | HTTPS | TCP | TCP_UDP | TLS | UDP
        backend_port     = number
        protocol_version = string # HTTP2 | HTTP1, default HTTP1
        target_type      = string # default instance

        connection_termination             = bool   # default false
        deregistration_delay               = number # default 300 seconds
        slow_start                         = number # default 0 seconds
        proxy_protocol_v2                  = bool   # default false
        lambda_multi_value_headers_enabled = bool   # default false
        load_balancing_algorithm_type      = string # default round_robin
        preserve_client_ip                 = bool
        ip_address_type                    = string # ipv4 | ipv6

        health_check = {
            enabled             = bool   # default true
            interval            = number # default 30 seconds
            path                = string
            port                = string # default traffic-port
            healthy_threshold   = number # default 3
            unhealthy_threshold = number # default 3
            timeout             = number # default 5 or 10 seconds
            protocol            = string # default HTTP
            matcher             = string
        }

        stickiness = {
            enabled         = bool   # default true
            cookie_duration = number # default 86400 (1 day)
            type            = string           # lb_cookie | app_cookie | source_ip
            cookie_name     = string
        }
    }
]
```

### Access Logs

```hcl
{
    enabled = bool # default true
    bucket  = string         # bucket must exist
    prefix  = string
}
```