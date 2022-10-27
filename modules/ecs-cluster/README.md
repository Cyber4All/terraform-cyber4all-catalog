<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 4.14)

## Modules

The following Modules are called:

### <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling)

Source: terraform-aws-modules/autoscaling/aws

Version: 6.5.2

### <a name="module_ecs"></a> [ecs](#module\_ecs)

Source: terraform-aws-modules/ecs/aws

Version: 4.1.1

### <a name="module_security_group"></a> [security\_group](#module\_security\_group)

Source: terraform-aws-modules/security-group/aws

Version: ~> 4.0

## Required Inputs

The following input variables are required:

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: maximum size of the autoscaling group

Type: `number`

### <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)

Description: the type of instance to launch (e.g. t2.micro)

Description: A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside.

Type: `list(string)`

### <a name="input_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#input\_s3\_log\_bucket\_name)

Description: s3 bucket name for logging

Type: `string`

### <a name="input_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#input\_s3\_log\_bucket\_name)

Description: s3 bucket name for logging

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: ID of the VPC where to create security group.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id)

Description: The AMI from which to launch the instance. (default: Amazon Linux AMI amzn-ami-2018.03.20220831 x86\_64 ECS HVM GP2, deprecated: Fri Aug 30 2024 20:24:19 GMT-0400)

Type: `string`

Default: `"ami-06e07b42f153830d8"`

### <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings)

Description: Specify volumes to attach to the instance besides the volumes specified by the AMI

Type: `list(any)`

Default: `[]`

### <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance)

Description: Indicates whether capacity rebalance is enabled.

Type: `bool`

Default: `true`

### <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity)

Description: capacity provider strategy

Type: `any`

Default: `{}`

### <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules)

Description: List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).

Type: `list(string)`

Default: `[]`

### <a name="input_egress_with_cidr_blocks"></a> [egress\_with\_cidr\_blocks](#input\_egress\_with\_cidr\_blocks)

Description: List of egress rules to create where 'cidr\_blocks' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics)

Description: A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`.

Type: `list(string)`

Default:

```json
[
  "GroupDesiredCapacity",
  "GroupInServiceCapacity",
  "GroupPendingCapacity",
  "GroupMinSize",
  "GroupMaxSize",
  "GroupInServiceInstances",
  "GroupPendingInstances",
  "GroupStandbyInstances",
  "GroupStandbyCapacity",
  "GroupTerminatingCapacity",
  "GroupTerminatingInstances",
  "GroupTotalCapacity",
  "GroupTotalInstances"
]
```

### <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description)

Description: Description of the role.

Type: `string`

Default: `"IAM Role managed by Terraform"`

### <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies)

Description: IAM policies to attach to the IAM role.

Type: `map(string)`

Default:

```json
{
  "AmazonEC2ContainerServiceforEC2Role": "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  "AmazonSSMManagedInstanceCore": "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
```

### <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules)

Description: List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf).

Type: `list(string)`

Default: `[]`

### <a name="input_ingress_with_cidr_blocks"></a> [ingress\_with\_cidr\_blocks](#input\_ingress\_with\_cidr\_blocks)

Description: List of ingress rules to create where 'cidr\_blocks' is used.

Type: `list(map(string))`

Default: `[]`

### <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)

Description: The type of the instance. If present then `instance_requirements` cannot be present.

Type: `string`

Default: `"t2.micro"`

### <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description)

Description: Description of the launch template.

Type: `string`

Default: `"Launch template managed by Terraform"`

### <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name)

Description: variables for managing scaling

Type: `any`

### <a name="input_max_size"></a> [max\_size](#input\_max\_size)

Description: The maximum size of the autoscaling group.

Type: `number`

Default: `1`

### <a name="input_min_size"></a> [min\_size](#input\_min\_size)

Description: The minimum size of the autoscaling group.

Type: `number`

Default: `1`

### <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description)

Description: Description of security group.

Type: `string`

Default: `"Security Group managed by Terraform"`

## Outputs

The following outputs are exported:

### <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn)

Description: The ARN for this AutoScaling Group

### <a name="output_autoscaling_group_availability_zones"></a> [autoscaling\_group\_availability\_zones](#output\_autoscaling\_group\_availability\_zones)

Description: The availability zones of the autoscale group

### <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id)

Description: The autoscaling group id

### <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn)

Description: ARN that identifies the cluster

### <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn)

Description: The ARN of the ECS cluster

### <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn)

Description: The ARN of the ECS cluster

### <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id)

Description: ID that identifies the cluster

### <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name)

Description: Name that identifies the cluster

### <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn)

Description: The Amazon Resource Name (ARN) specifying the IAM role

### <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn)

Description: The ARN of the launch template

### <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id)

Description: The ID of the launch template

### <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version)

Description: The latest version of the launch template

### <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn)

Description: The ARN of the security group

### <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id)

Description: The ID of the security group
<!-- END_TF_DOCS -->