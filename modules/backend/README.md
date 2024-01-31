# S3 Remote Backend Module

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.2.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 4.36)
## Sample Usage
```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"


	 # --------------------------------------------
	 # Required variables
	 # --------------------------------------------


	 # The name of the backend bucket
	 bucket_name  = string


	 # The name of the dynamodb table
	 dynamodb_table_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # Server side encryption algorithm for S3 bucket
	 sse_algorithm  = string



}
```
## Required Inputs

The following input variables are required:

### <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)

Description: The name of the backend bucket

Type: `string`

### <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name)

Description: The name of the dynamodb table

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm)

Description: Server side encryption algorithm for S3 bucket

Type: `string`

Default: `"AES256"`
## Outputs

The following outputs are exported:

### <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name)

Description: Name of S3 bucket

### <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region)

Description: AWS region S3 bucket is in
<!-- END_TF_DOCS -->