<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (1.2.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 4.0.0)

## Modules

The following Modules are called:

### <a name="module_iam_assumable_role"></a> [iam\_assumable\_role](#module\_iam\_assumable\_role)

Source: terraform-aws-modules/iam/aws//modules/iam-assumable-role

Version: 5.4.0

## Resources

The following resources are used by this module:

- [aws_dynamodb_table.terraform_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) (resource)
- [aws_iam_policy.tf_s3_backend_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
- [aws_s3_bucket.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_acl.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) (resource)
- [aws_s3_bucket_public_access_block.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_s3_bucket_versioning.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) (resource)
- [aws_iam_policy_document.tf_s3_backend_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

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

### <a name="input_environment"></a> [environment](#input\_environment)

Description: The environment type i.e (dev, staging, qa, prod)

Type: `string`

Default: `"staging"`

### <a name="input_path"></a> [path](#input\_path)

Description: The path to organize the policy in IAM

Type: `string`

Default: `"/"`

### <a name="input_region"></a> [region](#input\_region)

Description: AWS region where the bucket should be provisioned to

Type: `string`

Default: `"us-east-1"`

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

### <a name="output_s3_backend_policy_arn"></a> [s3\_backend\_policy\_arn](#output\_s3\_backend\_policy\_arn)

Description: ARN of IAM policy

### <a name="output_s3_backend_policy_name"></a> [s3\_backend\_policy\_name](#output\_s3\_backend\_policy\_name)

Description: Name of IAM policy

### <a name="output_s3_backend_role_arn"></a> [s3\_backend\_role\_arn](#output\_s3\_backend\_role\_arn)

Description: ARN of IAM role

### <a name="output_s3_backend_role_name"></a> [s3\_backend\_role\_name](#output\_s3\_backend\_role\_name)

Description: Name of IAM role
<!-- END_TF_DOCS -->