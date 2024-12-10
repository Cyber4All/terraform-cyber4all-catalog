# Secrets Manager

## Overview

This module contains Terraform code to deploy multiple [AWS SecretsManager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) secrets with key/value pairs defined. This module is mainly used to setup secrets manager and create the secret ARN references to be consumed by other modules.

<!-- Image or Arch diagram -->

## Learn

<!-- A few references to Secrets Manager (documentation, blog, etc...) -->

SecretsManager is a service that allows for the storage of sensitive secrets that are encrypted. This use case the module was developed for was for defining secrets that are used in applications. The applications that reference these values are retrieve the secrets as environment variable secrest in ECS or through the application code directly.

For more information about [using SecretsManager in ECS container definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-secrets-manager.html) read the considerations and implementation guide.

For more information about [retrieving secrets with the AWS API](https://docs.aws.amazon.com/secretsmanager/latest/userguide/retrieving-secrets.html) check out the guide for the language the application is developed in.

When defining the secret name and value, do not hard code sensitive values in the code! These values should injected on `apply`.

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
  

    	 secrets  = list(object({
    name                  = string
    description           = optional(string)
    environment_variables = map(string)
  }))
    

}
```
## Required Inputs

The following input variables are required:

### <a name="input_secrets"></a> [secrets](#input\_secrets)

Description: List of secrets that can be used to maintain the secret and its environment variables managed by the secret.

Type:

```hcl
list(object({
    name                  = string
    description           = optional(string)
    environment_variables = map(string)
  }))
```
## Outputs

The following outputs are exported:

### <a name="output_secret_arn_references"></a> [secret\_arn\_references](#output\_secret\_arn\_references)

Description: List of ARNs with appended references that can be used in other services such as ECS.

### <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns)

Description: List of ARNs for the secrets managed by the module.

### <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names)

Description: List of secret names for the secrets managed by the module.
<!-- END_TF_DOCS -->