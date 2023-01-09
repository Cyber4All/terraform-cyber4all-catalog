# Creating a Lambda Function using AWS Lambda Module

The example in the `main.tf` shows how the AWS Lambda module can be used to provision a function with IAM policies attached to the function.

In this case the artifact running in lambda is a ZIP artifact that was compiled prior to provisioning.

In terms of deployment, the zip would be created then `terraform apply` would be invoked to provision the new zip. We specifically set `publish = true` to ensure that new versions of artifacts were recorded by lambda. This enables us to revert to previous versions if needed.

Some of the other ways to deploy to lambda is by automatically compiling using terraform, storing the artifiact in S3, or using Docker.

Refer to [Terraform AWS Module Lambda](https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/4.7.1) for more information.
