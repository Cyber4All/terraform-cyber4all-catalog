# ECS-Cluster with Auto-Scaling Group Module Documentation
## Requirements

No requirements.

## Providers

No providers.

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

## Resources

No resources.

## Required Inputs

The following input variables are required:

### <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size)

Description: maximum size of the autoscaling group

Type: `number`

### <a name="input_s3\_log\_bucket\_name"></a> [s3\_log\_bucket\_name](#input\_s3\_log\_bucket\_name)

Description: s3 bucket name for logging

Type: `string`

### <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)

Description: the type of instance to launch (e.g. t2.micro)

Type: `string`

### <a name="input_launch_template_ami"></a> [launch\_template\_ami](#input\_launch\_template\_ami)

Description: the ami image number for the ec2 instance to be launched

Type: `string`

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: name that will be appended to all default names

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: VPC id to create the cluster in

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size)

Description: minimum size of the autoscaling group

Type: `number`

Default: `1`

### <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings)

Description: Specify volumes to attach to the instance besides the volumes specified by the AMI

Type:

```hcl
list(object({
    device_name = optional(string)
    no_device   = optional(number)

    ebs = optional(object({
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      volume_size           = optional(number)
      volume_type           = optional(string)
    }))
  }))
```

Default: `[]`

### <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance)

Description: Indicates whether capacity rebalance is enabled

Type: `bool`

Default: `true`

### <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy)

Description: capacity provider strategy. see [autoscaling\_capacity\_providers](#reference_autoscaling_capacity_providers)

Type:

```hcl
object({
    weight = optional(number)
    base   = optional(number)
  })
```

Default: `{}`

### <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity)

Description: desired capacity

Type: `number`

Default: `2`

### <a name="input_egress_with_cidr_blocks"></a> [egress\_with\_cidr\_blocks](#input\_egress\_with\_cidr\_blocks)

Description: list of egress cidr blocks for the security group to be created

Type: `list(map(string))`

Default: `[]`

### <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name)

Description: name for the IAM instance profile

Type: `string`

Default: `""`

### <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description)

Description: the description for the iam role to be created

Type: `string`

Default: `""`

### <a name="input_ingress_with_cidr_blocks"></a> [ingress\_with\_cidr\_blocks](#input\_ingress\_with\_cidr\_blocks)

Description: list of ingress cidr blocks for the security group to be created

Type: `list(map(string))`

Default: `[]`

### <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description)

Description: description of the launch template

Type: `string`

Default: `""`

### <a name="input_managed_scaling"></a> [managed\_scaling](#input\_managed\_scaling)

Description: default\_capacity\_provider\_strategy. see [autoscaling\_capacity\_providers](#reference_autoscaling_capacity_providers)

Type:

```hcl
object({
    maximum_scaling_step_size = optional(number)
    minimum_scaling_step_size = optional(number)
    status                    = optional(string)
    target_capacity           = optional(number)
  })
```

Default: `{}`

### <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets)

Description: the list of public subnets from the vpc

Type: `list(string)`

Default: `[]`

### <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets)

Description: the list of public subnets from the vpc

Type: `list(string)`

Default: `[]`

### <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description)

Description: the description of the security group to create

Type: `string`

Default: `"default security group description"`

## Outputs

The following outputs are exported:

### <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn)

Description: the arn of the generated autoscaling group

### <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id)

Description: the id of the generated autoscaling group

### <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id)

Description: the id of the ECS cluster

### <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name)

Description: The name of ECS cluster

### <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn)

Description: the arn of the security group

### <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id)

Description: the id of the security group created

## Autoscaling capacity provider reference<a name="reference_autoscaling_capacity_providers"></a>
this is the documentation for autoscaling capacity providers from the ECS module on the terraform registry found [here](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest). The Variable was split up in this module to preserve granularity, while still making them optional.

```
variable "autoscaling_capacity_providers" {
  type = map(object({
    auto_scaling_group_arn = optional(string)

    managed_termination_protection = optional(string)

    managed_scaling = optional(object({
      maximum_scaling_step_size = optional(number)
      minimum_scaling_step_size = optional(number)
      status                    = optional(string)
      target_capacity           = optional(number)
    }))

    default_capacity_provider_strategy = optional(object({
      weight = optional(number)
      base   = optional(number)
    }))
  }))
}
```