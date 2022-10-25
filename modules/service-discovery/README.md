<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.2.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 4.36)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 4.36)

## Resources

The following resources are used by this module:

- [aws_service_discovery_private_dns_namespace.namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the namespace.

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: The ID of VPC that you want to associate the namespace with.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: The description that you specify for the namespace when you create it.

Type: `string`

Default: `"Private DNS Namespace Managed by Terraform"`

## Outputs

The following outputs are exported:

### <a name="output_arn"></a> [arn](#output\_arn)

Description: The ARN that Amazon Route 53 assigns to the namespace when you create it.

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of a namespace.
<!-- END_TF_DOCS -->