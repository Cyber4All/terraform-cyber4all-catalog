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
	 primary_bucket_name  = string


	 # The name of the S3 bucket.
	 replica_bucket_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # The ID of the replication configuration rule.
	 bucket_replication_configuration_rule_id  = string


	 # Whether or not to enable full lifecycle management on the S3 bucket.
	 enable_storage_lifecycles  = bool


	 # Whether or not to enable full lifecycle management on the S3 bucket. Defaults to ture.
	 full_lifecycle_management  = bool


	 # The ID of the transition lifecycle rule.
	 lifecycle_transitioin_id  = string


	 # The ID of the versioning lifecycle rule.
	 lifecycle_versioning_id  = string


	 # The ACL option to apply to the primary S3 bucket.
	 pimary_bucket_acl  = string


	 # The AWS region in which to create the S3 bucket.
	 priamry_region  = string


	 # The default storage class for objects in the destination bucket. Valid values are STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE, or OUTPOSTS. Defaults to STANDARD.
	 replica_configuration_destination_storage_class  = string


	 # The replication configuration status. Valid values are Enabled or Disabled.
	 replica_configuration_status  = string


	 # The AWS region in which to create the S3 bucket.
	 replica_region  = string


	 # The storage class to transition to after 30 days.
	 transition_30_storage_class  = string


	 # The storage class to transition to after 90 days.
	 transition_90_storage_class  = string



}
```
## Required Inputs

The following input variables are required:

### <a name="input_primary_bucket_name"></a> [primary\_bucket\_name](#input\_primary\_bucket\_name)

Description: The name of the S3 bucket.

Type: `string`

### <a name="input_replica_bucket_name"></a> [replica\_bucket\_name](#input\_replica\_bucket\_name)

Description: The name of the S3 bucket.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_bucket_replication_configuration_rule_id"></a> [bucket\_replication\_configuration\_rule\_id](#input\_bucket\_replication\_configuration\_rule\_id)

Description: The ID of the replication configuration rule.

Type: `string`

Default: `"bucket-replication-rule"`

### <a name="input_enable_storage_lifecycles"></a> [enable\_storage\_lifecycles](#input\_enable\_storage\_lifecycles)

Description: Whether or not to enable full lifecycle management on the S3 bucket.

Type: `bool`

Default: `true`

### <a name="input_full_lifecycle_management"></a> [full\_lifecycle\_management](#input\_full\_lifecycle\_management)

Description: Whether or not to enable full lifecycle management on the S3 bucket. Defaults to ture.

Type: `bool`

Default: `true`

### <a name="input_lifecycle_transitioin_id"></a> [lifecycle\_transitioin\_id](#input\_lifecycle\_transitioin\_id)

Description: The ID of the transition lifecycle rule.

Type: `string`

Default: `"downgrade-storage-class"`

### <a name="input_lifecycle_versioning_id"></a> [lifecycle\_versioning\_id](#input\_lifecycle\_versioning\_id)

Description: The ID of the versioning lifecycle rule.

Type: `string`

Default: `"expire-noncurrent-versions"`

### <a name="input_pimary_bucket_acl"></a> [pimary\_bucket\_acl](#input\_pimary\_bucket\_acl)

Description: The ACL option to apply to the primary S3 bucket.

Type: `string`

Default: `"private"`

### <a name="input_priamry_region"></a> [priamry\_region](#input\_priamry\_region)

Description: The AWS region in which to create the S3 bucket.

Type: `string`

Default: `"us-east-1"`

### <a name="input_replica_configuration_destination_storage_class"></a> [replica\_configuration\_destination\_storage\_class](#input\_replica\_configuration\_destination\_storage\_class)

Description: The default storage class for objects in the destination bucket. Valid values are STANDARD, REDUCED\_REDUNDANCY, STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, DEEP\_ARCHIVE, or OUTPOSTS. Defaults to STANDARD.

Type: `string`

Default: `"STANDARD"`

### <a name="input_replica_configuration_status"></a> [replica\_configuration\_status](#input\_replica\_configuration\_status)

Description: The replication configuration status. Valid values are Enabled or Disabled.

Type: `string`

Default: `"Enabled"`

### <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region)

Description: The AWS region in which to create the S3 bucket.

Type: `string`

Default: `"us-east-2"`

### <a name="input_transition_30_storage_class"></a> [transition\_30\_storage\_class](#input\_transition\_30\_storage\_class)

Description: The storage class to transition to after 30 days.

Type: `string`

Default: `"STANDARD_IA"`

### <a name="input_transition_90_storage_class"></a> [transition\_90\_storage\_class](#input\_transition\_90\_storage\_class)

Description: The storage class to transition to after 90 days.

Type: `string`

Default: `"GLACIER"`
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