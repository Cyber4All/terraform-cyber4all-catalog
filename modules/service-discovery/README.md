<!-- BEGIN_TF_DOCS -->


## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws)

## Resources

The following resources are used by this module:

- [aws_service_discovery_private_dns_namespace.namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: n/a

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: n/a

Type: `string`

Default: `""`

## Outputs

The following outputs are exported:

### <a name="output_arn"></a> [arn](#output\_arn)

Description: The ARN that Amazon Route 53 assigns to the namespace when you create it.
<!-- END_TF_DOCS -->