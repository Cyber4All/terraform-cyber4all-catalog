# S3 Artifacts Module
## Todo: write it
<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)
## Sample Usage
```hcl
terraform {
	 source = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"
}

inputs = {


  	 # --------------------------------------------
  	 # Required variables
  	 # --------------------------------------------
  

    	 bucket_name  = string
    

  	 # --------------------------------------------
  	 # Optional variables
  	 # --------------------------------------------
  

    	 enable_public_access  = bool
    

    	 enable_replica  = bool
    

    	 enable_storage_class_transition  = bool
    

    	 primary_region  = string
    

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

### <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access)

Description: Whether or not to enable public access to the S3 bucket. Defaults to false.

Type: `bool`

Default: `false`

### <a name="input_enable_replica"></a> [enable\_replica](#input\_enable\_replica)

Description: Whether or not to create a replica bucket in a different region. Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_enable_storage_class_transition"></a> [enable\_storage\_class\_transition](#input\_enable\_storage\_class\_transition)

Description: Whether or not to enable full lifecycle management with both storage transitions on the S3 bucket. Defaults to false and is an opt-in feature since bucket versioning will always be enabled.

Type: `bool`

Default: `false`

### <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region)

Description: The AWS region in which to create the S3 bucket.

Type: `string`

Default: `"us-east-1"`

### <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region)

Description: The AWS region in which to create the replica S3 bucket.

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