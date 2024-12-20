<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

- <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) (>= 1.12.1)
## Sample Usage
```hcl
terraform {
	 source = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"
}

inputs = {


  	 # --------------------------------------------
  	 # Required variables
  	 # --------------------------------------------
  

    	 project_name  = string
    

  	 # --------------------------------------------
  	 # Optional variables
  	 # --------------------------------------------
  

    	 authorized_iam_roles  = map(string)
    

    	 authorized_iam_users  = map(string)
    

}
```
## Required Inputs

The following input variables are required:

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: Name of the project as it appears in Atlas to deploy the cluster into.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_authorized_iam_roles"></a> [authorized\_iam\_roles](#input\_authorized\_iam\_roles)

Description: Create a map of AWS IAM roles to assign an admin, readWrite, or read database role to the cluster's databases.

Type: `map(string)`

Default: `{}`

### <a name="input_authorized_iam_users"></a> [authorized\_iam\_users](#input\_authorized\_iam\_users)

Description: Create a map of AWS IAM users to assign an admin, readWrite, or read database role to the project's databases.

Type: `map(string)`

Default: `{}`
## Outputs

The following outputs are exported:

### <a name="output_authorized_iam_roles"></a> [authorized\_iam\_roles](#output\_authorized\_iam\_roles)

Description: The list of IAM roles authorized to access the project.

### <a name="output_authorized_iam_users"></a> [authorized\_iam\_users](#output\_authorized\_iam\_users)

Description: The list of IAM users authorized to access the project.
<!-- END_TF_DOCS -->