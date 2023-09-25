# Secrets Manager

## Overview

<!-- Image or Arch diagram -->

## Features

<!-- A list of what that the module can do -->

## Learn

<!-- A few references to Secrets Manager (documentation, blog, etc...) -->

## Sample Usage

```hcl
# main.tf

# ------------------------------------------------------------------------------------------------------
# DEPLOY CYBER4ALL'S SECRETS MANAGER MODULE
# ------------------------------------------------------------------------------------------------------

module "secrets-manager" {

    source = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/secrets-manager?ref=v1.1.0"

    # --------------------------------------------------------------------------------------------------
    # REQUIRED VARIABLES
    # --------------------------------------------------------------------------------------------------

    # List of secrets that can be used to maintain the secret and its environment variables managed by the secret.
    secrets = <list(object(
        name        = string
        description = optional(string)
        environment = list(object(
            name  = string
            value = string
        ))
    ))>

}

```

## Reference

<!-- (Required/Optional Inputs, Outputs) -->

### Required Inputs

The following input variables are required:

#### <a name="input_secrets"></a> [secrets](#input\_secrets)

Description: List of secrets that can be used to maintain the secret and its environment variables managed by the secret.

Type:

```hcl
list(object({
    name        = string
    description = optional(string)
    environment = list(object({
      name  = string
      value = string
    }))
  }))
```

### Optional Inputs

No optional inputs.

### Outputs

The following outputs are exported:

#### <a name="output_secret_arn_references"></a> [secret\_arn\_references](#output\_secret\_arn\_references)

Description: List of ARNs with appended references that can be used in other services such as ECS.

#### <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns)

Description: List of ARNs for the secrets managed by the module.