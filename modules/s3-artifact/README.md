# S3 Artifacts Module
## Todo: write it
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


	 # The name of the S3 bucket.
	 bucket_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # Whether or not to enable versioning on the S3 bucket.
	 enable_bucket_versioning  = bool


	 # Whether or not to enable full lifecycle management with both storage transitions and object versions on the S3 bucket. Defaults to ture. If set to false, only object versioning will be enabled.
	 enable_lifecycle_management  = bool


	 # Whether or not to create a replica bucket in a different region. Defaults to true.
	 enable_replica  = bool


	 # The AWS region in which to create the S3 bucket.
	 primary_region  = string


	 # The AWS region in which to create the S3 bucket.
	 replica_region  = string



}
```
## Required Inputs

The following input variables are required:

### <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)

Description: The name of the S3 bucket.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_bucket_versioning"></a> [enable\_bucket\_versioning](#input\_enable\_bucket\_versioning)

Description: Whether or not to enable versioning on the S3 bucket.

Type: `bool`

Default: `true`

### <a name="input_enable_lifecycle_management"></a> [enable\_lifecycle\_management](#input\_enable\_lifecycle\_management)

Description: Whether or not to enable full lifecycle management with both storage transitions and object versions on the S3 bucket. Defaults to ture. If set to false, only object versioning will be enabled.

Type: `bool`

Default: `true`

### <a name="input_enable_replica"></a> [enable\_replica](#input\_enable\_replica)

Description: Whether or not to create a replica bucket in a different region. Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region)

Description: The AWS region in which to create the S3 bucket.

Type: `string`

Default: `"us-east-1"`

### <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region)

Description: The AWS region in which to create the S3 bucket.

Type: `string`

Default: `"us-east-2"`
## Outputs

The following outputs are exported:

### <a name="output_primary_arn"></a> [primary\_arn](#output\_primary\_arn)

Description: The ARN of the bucket.

### <a name="output_primary_domain_name"></a> [primary\_domain\_name](#output\_primary\_domain\_name)

Description: The bucket domain name.

### <a name="output_primary_id"></a> [primary\_id](#output\_primary\_id)

Description: The name of the bucket.

### <a name="output_replica_arn"></a> [replica\_arn](#output\_replica\_arn)

Description: The ARN of the bucket.

### <a name="output_replica_domain_name"></a> [replica\_domain\_name](#output\_replica\_domain\_name)

Description: The bucket domain name.

### <a name="output_replica_id"></a> [replica\_id](#output\_replica\_id)

Description: The name of the bucket.
<!-- END_TF_DOCS -->