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


	 # The name of the ALB.
	 alb_name  = string


	 # The name of the hosted zone where the ALB DNS record will be created.
	 hosted_zone_name  = string


	 # The VPC ID where the ALB will be created.
	 vpc_id  = string


	 # The ids of the subnets that the ALB can use to source its IP.
	 vpc_subnet_ids  = list(string)


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # Enable access logs for the ALB.
	 enable_access_logs  = bool


	 # Creates an HTTPS listener for the ALB. When enabled the ALB will redirect HTTP traffic to HTTPS automatically.
	 enable_https_listener  = bool



}
```
## Required Inputs

The following input variables are required:

### <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name)

Description: The name of the ALB.

Type: `string`

### <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name)

Description: The name of the hosted zone where the ALB DNS record will be created.

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: The VPC ID where the ALB will be created.

Type: `string`

### <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids)

Description: The ids of the subnets that the ALB can use to source its IP.

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs)

Description: Enable access logs for the ALB.

Type: `bool`

Default: `false`

### <a name="input_enable_https_listener"></a> [enable\_https\_listener](#input\_enable\_https\_listener)

Description: Creates an HTTPS listener for the ALB. When enabled the ALB will redirect HTTP traffic to HTTPS automatically.

Type: `bool`

Default: `true`
## Outputs

The following outputs are exported:

### <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn)

Description: n/a

### <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name)

Description: n/a

### <a name="output_alb_hosted_zone_id"></a> [alb\_hosted\_zone\_id](#output\_alb\_hosted\_zone\_id)

Description: n/a

### <a name="output_alb_name"></a> [alb\_name](#output\_alb\_name)

Description: n/a

### <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id)

Description: n/a

### <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn)

Description: n/a

### <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn)

Description: n/a
<!-- END_TF_DOCS -->