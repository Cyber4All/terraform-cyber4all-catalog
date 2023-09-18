<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

## Sample Usage

```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"


	 # --------------------------------------------
	 # Required variables
	 # --------------------------------------------


	 # The name of the VPC.
	 vpc_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # Whether or not to create a NAT gateway.
	 create_nat_gateway  = bool


	 # Whether or not to create private subnets.
	 create_private_subnets  = bool


	 # Whether or not to create public subnets.
	 create_public_subnets  = bool


	 # How many AWS Availability Zones (AZs) to use. One subnet of each type (public, private app) will be created in each AZ. Note that this must be less than or equal to the total number of AZs in a region. A value of null means all AZs should be used. For example, if you specify 3 in a region with 5 AZs, subnets will be created in just 3 AZs instead of all 5. Defaults to all AZs in a region.
	 num_availability_zones  = number



}
```
## Required Inputs

The following input variables are required:

### <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name)

Description: The name of the VPC.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_nat_gateway"></a> [create\_nat\_gateway](#input\_create\_nat\_gateway)

Description: Whether or not to create a NAT gateway.

Type: `bool`

Default: `true`

### <a name="input_create_private_subnets"></a> [create\_private\_subnets](#input\_create\_private\_subnets)

Description: Whether or not to create private subnets.

Type: `bool`

Default: `true`

### <a name="input_create_public_subnets"></a> [create\_public\_subnets](#input\_create\_public\_subnets)

Description: Whether or not to create public subnets.

Type: `bool`

Default: `true`

### <a name="input_num_availability_zones"></a> [num\_availability\_zones](#input\_num\_availability\_zones)

Description: How many AWS Availability Zones (AZs) to use. One subnet of each type (public, private app) will be created in each AZ. Note that this must be less than or equal to the total number of AZs in a region. A value of null means all AZs should be used. For example, if you specify 3 in a region with 5 AZs, subnets will be created in just 3 AZs instead of all 5. Defaults to all AZs in a region.

Type: `number`

Default: `null`
## Outputs

The following outputs are exported:

### <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones)

Description: n/a

### <a name="output_nat_gateway_count"></a> [nat\_gateway\_count](#output\_nat\_gateway\_count)

Description: n/a

### <a name="output_nat_gateway_public_ips"></a> [nat\_gateway\_public\_ips](#output\_nat\_gateway\_public\_ips)

Description: n/a

### <a name="output_num_availability_zones"></a> [num\_availability\_zones](#output\_num\_availability\_zones)

Description: n/a

### <a name="output_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#output\_private\_subnet\_cidr\_blocks)

Description: n/a

### <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids)

Description: n/a

### <a name="output_public_subnet_cidr_blocks"></a> [public\_subnet\_cidr\_blocks](#output\_public\_subnet\_cidr\_blocks)

Description: output "private\_subnet\_route\_table\_ids" {} output "private\_subnets" {} output "private\_subnets\_route\_table\_ids" {}

### <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids)

Description: n/a

### <a name="output_public_subnet_route_table_id"></a> [public\_subnet\_route\_table\_id](#output\_public\_subnet\_route\_table\_id)

Description: n/a

### <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block)

Description: output "public\_subnets" {} output "public\_subnets\_network\_acl\_id" {}

### <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id)

Description: n/a

### <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name)

Description: n/a
<!-- END_TF_DOCS -->