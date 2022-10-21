<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (1.2.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (4.29.0)

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

### <a name="input_access_log_bucket"></a> [access\_log\_bucket](#input\_access\_log\_bucket)

Description: Name of S3 bucket to forward access logs to

Type: `string`

Default: `null`

### <a name="input_create_external_alb"></a> [create\_external\_alb](#input\_create\_external\_alb)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_create_internal_alb"></a> [create\_internal\_alb](#input\_create\_internal\_alb)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_external_http_tcp_listener_rules"></a> [external\_http\_tcp\_listener\_rules](#input\_external\_http\_tcp\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_external_http_tcp_listeners"></a> [external\_http\_tcp\_listeners](#input\_external\_http\_tcp\_listeners)

Description: A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_external_https_listener_rules"></a> [external\_https\_listener\_rules](#input\_external\_https\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_external_https_listeners"></a> [external\_https\_listeners](#input\_external\_https\_listeners)

Description: A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_external_sg_description"></a> [external\_sg\_description](#input\_external\_sg\_description)

Description: n/a

Type: `string`

Default: `"Security group attached to external alb managed by terraform"`

### <a name="input_external_sg_egress_with_cidr_blocks"></a> [external\_sg\_egress\_with\_cidr\_blocks](#input\_external\_sg\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used (set to [] if using external\_sg\_egress\_with\_source\_security\_group\_id, see main.tf locals)

Type: `list(map(string))`

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

Type: `list(map(string))`

Default: `[]`

### <a name="input_external_sg_ingress_with_cidr_blocks"></a> [external\_sg\_ingress\_with\_cidr\_blocks](#input\_external\_sg\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used

Type: `list(map(string))`

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

Type: `list(map(string))`

Default: `[]`

### <a name="input_external_target_groups"></a> [external\_target\_groups](#input\_external\_target\_groups)

Description: A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port

Type: `any`

Default: `[]`

### <a name="input_internal_http_tcp_listener_rules"></a> [internal\_http\_tcp\_listener\_rules](#input\_internal\_http\_tcp\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_internal_http_tcp_listeners"></a> [internal\_http\_tcp\_listeners](#input\_internal\_http\_tcp\_listeners)

Description: A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_internal_https_listener_rules"></a> [internal\_https\_listener\_rules](#input\_internal\_https\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_internal_https_listeners"></a> [internal\_https\_listeners](#input\_internal\_https\_listeners)

Description: A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index])

Type: `any`

Default: `[]`

### <a name="input_internal_sg_description"></a> [internal\_sg\_description](#input\_internal\_sg\_description)

Description: n/a

Type: `string`

Default: `"Security group attached to internal alb managed by terraform"`

### <a name="input_internal_sg_egress_with_cidr_blocks"></a> [internal\_sg\_egress\_with\_cidr\_blocks](#input\_internal\_sg\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used (set to [] if using internal\_sg\_egress\_with\_source\_security\_group\_id, see main.tf locals)

Type: `list(map(string))`

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

Type: `list(map(string))`

Default: `[]`

### <a name="input_internal_sg_ingress_with_cidr_blocks"></a> [internal\_sg\_ingress\_with\_cidr\_blocks](#input\_internal\_sg\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used (if vpc\_cidr is set, default rules set with cidr\_blocks, see main.tf locals)

Type: `list(map(string))`

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

Type: `list(map(string))`

Default: `[]`

### <a name="input_internal_target_groups"></a> [internal\_target\_groups](#input\_internal\_target\_groups)

Description: A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port

Type: `any`

Default: `[]`

### <a name="input_region"></a> [region](#input\_region)

Description: n/a

Type: `string`

Default: `"us-east-1"`
<!-- END_TF_DOCS -->