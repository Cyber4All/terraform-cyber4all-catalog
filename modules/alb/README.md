<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 4.27.0)

## Sample Usage

```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"


	 # --------------------------------------------
	 # Required variables
	 # --------------------------------------------


	 # Name that will prepend all resources.
	 project_name  = string


	 # ID of the VPC where to create security group.
	 vpc_id  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # The S3 bucket name to store the logs in.
	 access_log_bucket  = string


	 # Controls if the External Application Load Balancer should be created
	 create_external_alb  = bool


	 # Controls if the Internal Application Load Balancer should be created
	 create_internal_alb  = bool


	 # List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).
	 external_egress_rules  = list(string)


	 # List of egress rules to create where 'cidr_blocks' is used.
	 external_egress_with_cidr_blocks  = list(map(string))


	 # List of egress rules to create where 'source_security_group_id' is used.
	 external_egress_with_source_security_group_id  = list(map(string))


	 # A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index]).
	 external_http_tcp_listener_rules  = any


	 # A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index]).
	 external_http_tcp_listeners  = any


	 # A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index]).
	 external_https_listener_rules  = any


	 # A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index]).
	 external_https_listeners  = any


	 # List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).
	 external_ingress_rules  = list(string)


	 # List of ingress rules to create where 'cidr_blocks' is used.
	 external_ingress_with_cidr_blocks  = list(map(string))


	 # List of ingress rules to create where 'source_security_group_id' is used.
	 external_ingress_with_source_security_group_id  = list(map(string))


	 # Description of security group.
	 external_sg_description  = string


	 # A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port.
	 external_target_groups  = any


	 # List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).
	 internal_egress_rules  = list(string)


	 # List of egress rules to create where 'cidr_blocks' is used.
	 internal_egress_with_cidr_blocks  = list(map(string))


	 # List of egress rules to create where 'source_security_group_id' is used.
	 internal_egress_with_source_security_group_id  = list(map(string))


	 # A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index].
	 internal_http_tcp_listener_rules  = any


	 # A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index]).
	 internal_http_tcp_listeners  = any


	 # A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index]).
	 internal_https_listener_rules  = any


	 # A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index]).
	 internal_https_listeners  = any


	 # List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).
	 internal_ingress_rules  = list(string)


	 # List of ingress rules to create where 'cidr_blocks' is used.
	 internal_ingress_with_cidr_blocks  = list(map(string))


	 # List of ingress rules to create where 'source_security_group_id' is used.
	 internal_ingress_with_source_security_group_id  = list(map(string))


	 # Description of security group.
	 internal_sg_description  = string


	 # A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port.
	 internal_target_groups  = any


	 # List of private subnet IDs to deploy internal ALB into (required if create_internal_alb == true)
	 private_subnet_ids  = list(string)


	 # List of public subnet ARNs to deploy external ALB into (required if create_external_alb == true)
	 public_subnet_ids  = list(string)



}
```
## Required Inputs

The following input variables are required:

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: Name that will prepend all resources.

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: ID of the VPC where to create security group.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_access_log_bucket"></a> [access\_log\_bucket](#input\_access\_log\_bucket)

Description: The S3 bucket name to store the logs in.

Type: `string`

Default: `null`

### <a name="input_create_external_alb"></a> [create\_external\_alb](#input\_create\_external\_alb)

Description: Controls if the External Application Load Balancer should be created

Type: `bool`

Default: `true`

### <a name="input_create_internal_alb"></a> [create\_internal\_alb](#input\_create\_internal\_alb)

Description: Controls if the Internal Application Load Balancer should be created

Type: `bool`

Default: `true`

### <a name="input_external_egress_rules"></a> [external\_egress\_rules](#input\_external\_egress\_rules)

Description: List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).

Type: `list(string)`

Default: `[]`

### <a name="input_external_egress_with_cidr_blocks"></a> [external\_egress\_with\_cidr\_blocks](#input\_external\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_external_egress_with_source_security_group_id"></a> [external\_egress\_with\_source\_security\_group\_id](#input\_external\_egress\_with\_source\_security\_group\_id)

Description: List of egress rules to create where 'source\_security\_group\_id' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_external_http_tcp_listener_rules"></a> [external\_http\_tcp\_listener\_rules](#input\_external\_http\_tcp\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_external_http_tcp_listeners"></a> [external\_http\_tcp\_listeners](#input\_external\_http\_tcp\_listeners)

Description: A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_external_https_listener_rules"></a> [external\_https\_listener\_rules](#input\_external\_https\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_external_https_listeners"></a> [external\_https\_listeners](#input\_external\_https\_listeners)

Description: A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_external_ingress_rules"></a> [external\_ingress\_rules](#input\_external\_ingress\_rules)

Description: List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).

Type: `list(string)`

Default: `[]`

### <a name="input_external_ingress_with_cidr_blocks"></a> [external\_ingress\_with\_cidr\_blocks](#input\_external\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_external_ingress_with_source_security_group_id"></a> [external\_ingress\_with\_source\_security\_group\_id](#input\_external\_ingress\_with\_source\_security\_group\_id)

Description: List of ingress rules to create where 'source\_security\_group\_id' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_external_sg_description"></a> [external\_sg\_description](#input\_external\_sg\_description)

Description: Description of security group.

Type: `string`

Default: `"External ALB Security Group managed by Terraform"`

### <a name="input_external_target_groups"></a> [external\_target\_groups](#input\_external\_target\_groups)

Description: A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port.

Type: `any`

Default: `[]`

### <a name="input_internal_egress_rules"></a> [internal\_egress\_rules](#input\_internal\_egress\_rules)

Description: List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).

Type: `list(string)`

Default: `[]`

### <a name="input_internal_egress_with_cidr_blocks"></a> [internal\_egress\_with\_cidr\_blocks](#input\_internal\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_internal_egress_with_source_security_group_id"></a> [internal\_egress\_with\_source\_security\_group\_id](#input\_internal\_egress\_with\_source\_security\_group\_id)

Description: List of egress rules to create where 'source\_security\_group\_id' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_internal_http_tcp_listener_rules"></a> [internal\_http\_tcp\_listener\_rules](#input\_internal\_http\_tcp\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index].

Type: `any`

Default: `[]`

### <a name="input_internal_http_tcp_listeners"></a> [internal\_http\_tcp\_listeners](#input\_internal\_http\_tcp\_listeners)

Description: A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_internal_https_listener_rules"></a> [internal\_https\_listener\_rules](#input\_internal\_https\_listener\_rules)

Description: A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_internal_https_listeners"></a> [internal\_https\_listeners](#input\_internal\_https\_listeners)

Description: A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index]).

Type: `any`

Default: `[]`

### <a name="input_internal_ingress_rules"></a> [internal\_ingress\_rules](#input\_internal\_ingress\_rules)

Description: List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).

Type: `list(string)`

Default: `[]`

### <a name="input_internal_ingress_with_cidr_blocks"></a> [internal\_ingress\_with\_cidr\_blocks](#input\_internal\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_internal_ingress_with_source_security_group_id"></a> [internal\_ingress\_with\_source\_security\_group\_id](#input\_internal\_ingress\_with\_source\_security\_group\_id)

Description: List of ingress rules to create where 'source\_security\_group\_id' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_internal_sg_description"></a> [internal\_sg\_description](#input\_internal\_sg\_description)

Description: Description of security group.

Type: `string`

Default: `"External ALB Security Group managed by Terraform"`

### <a name="input_internal_target_groups"></a> [internal\_target\_groups](#input\_internal\_target\_groups)

Description: A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port.

Type: `any`

Default: `[]`

### <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids)

Description: List of private subnet IDs to deploy internal ALB into (required if create\_internal\_alb == true)

Type: `list(string)`

Default: `[]`

### <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids)

Description: List of public subnet ARNs to deploy external ALB into (required if create\_external\_alb == true)

Type: `list(string)`

Default: `[]`
## Outputs

The following outputs are exported:

### <a name="output_external_lb_arn"></a> [external\_lb\_arn](#output\_external\_lb\_arn)

Description: The ID and ARN of the load balancer we created.

### <a name="output_external_lb_dns_name"></a> [external\_lb\_dns\_name](#output\_external\_lb\_dns\_name)

Description: The DNS name of the load balancer.

### <a name="output_external_lb_id"></a> [external\_lb\_id](#output\_external\_lb\_id)

Description: The ID and ARN of the load balancer we created.

### <a name="output_external_security_group_arn"></a> [external\_security\_group\_arn](#output\_external\_security\_group\_arn)

Description: The ARN of the external alb security group

### <a name="output_external_security_group_id"></a> [external\_security\_group\_id](#output\_external\_security\_group\_id)

Description: The ID of the external alb security group

### <a name="output_external_target_group_arn_suffixes"></a> [external\_target\_group\_arn\_suffixes](#output\_external\_target\_group\_arn\_suffixes)

Description: ARN suffixes of our target groups - can be used with CloudWatch.

### <a name="output_external_target_group_arns"></a> [external\_target\_group\_arns](#output\_external\_target\_group\_arns)

Description: ARNs of the target groups. Useful for passing to your Auto Scaling group.

### <a name="output_external_target_group_names"></a> [external\_target\_group\_names](#output\_external\_target\_group\_names)

Description: Name of the target group. Useful for passing to your CodeDeploy Deployment Group.

### <a name="output_internal_lb_arn"></a> [internal\_lb\_arn](#output\_internal\_lb\_arn)

Description: The ID and ARN of the load balancer we created.

### <a name="output_internal_lb_dns_name"></a> [internal\_lb\_dns\_name](#output\_internal\_lb\_dns\_name)

Description: The DNS name of the load balancer.

### <a name="output_internal_lb_id"></a> [internal\_lb\_id](#output\_internal\_lb\_id)

Description: The ID and ARN of the load balancer we created.

### <a name="output_internal_security_group_arn"></a> [internal\_security\_group\_arn](#output\_internal\_security\_group\_arn)

Description: The ARN of the internal alb security group

### <a name="output_internal_security_group_id"></a> [internal\_security\_group\_id](#output\_internal\_security\_group\_id)

Description: The ID of the internal alb security group

### <a name="output_internal_target_group_arn_suffixes"></a> [internal\_target\_group\_arn\_suffixes](#output\_internal\_target\_group\_arn\_suffixes)

Description: ARN suffixes of our target groups - can be used with CloudWatch.

### <a name="output_internal_target_group_arns"></a> [internal\_target\_group\_arns](#output\_internal\_target\_group\_arns)

Description: ARNs of the target groups. Useful for passing to your Auto Scaling group.

### <a name="output_internal_target_group_names"></a> [internal\_target\_group\_names](#output\_internal\_target\_group\_names)

Description: Name of the target group. Useful for passing to your CodeDeploy Deployment Group.
<!-- END_TF_DOCS -->