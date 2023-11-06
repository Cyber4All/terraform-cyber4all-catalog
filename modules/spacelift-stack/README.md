<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

- <a name="requirement_spacelift"></a> [spacelift](#requirement\_spacelift) (>= 1.6.0)

## Sample Usage

```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"


	 # --------------------------------------------
	 # Required variables
	 # --------------------------------------------


	 # GitHub branch to apply changes to
	 branch  = string


	 # Name of the repository, without the owner slug prefix
	 repository  = string


	 # Name of the stack - should be unique in one account. A naming convention of <environment>-<project>-<module>-<region> is recommended.
	 stack_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # List of Spacelift context IDs to attach to the stack
	 context_ids  = list(string)


	 # Description of the stack
	 description  = string


	 # Whether to enable administrative access to the stack to manage other Spacelift stacks and resources. Automically disables IAM integration.
	 enable_admin_stack  = bool


	 # Whether to enable automatic apply of changes to the stack
	 enable_autodeploy  = bool


	 # Whether to enable an IAM role to be created for the stack.
	 enable_iam_integration  = bool


	 # Whether to protect the stack from deletion. This value should only be changed if you understand the implications of doing so.
	 enable_protect_from_deletion  = bool


	 # Whether to enable state management for the stack. If disabled, the implementation of the module should define another remote backend such as S3.
	 enable_state_management  = bool


	 # Stack scoped environment variables to set for the stack. These variables will be available to all Terraform runs for the stack. All variables will be prefixed automatically with TF_VAR_.
	 environment_variables  = map(string)


	 # IAM role policy ARNs to attach to the stack's IAM role. The IAM role will be created if create_iam_role is true. The policies ARNs can either be ARNs of AWS managed policies or custom policies.
	 iam_role_policy_arns  = list(string)


	 # Labels to assign to the stack.
	 labels  = list(string)


	 # Path to the root of the project
	 path  = string


	 # List of Spacelift policy IDs to attach to the stack
	 policy_ids  = list(string)


	 # A map of stack ids that this stack depends on. The key is the stack id and the value is a map of environment variables that are defined by outputs of the stack. i.e { "stack-id" = { "vpc_id" = "vpc_id" } }. The input name is automatically prefixed with TF_VAR_.
	 stack_dependencies  = map(any)


	 # Terraform version to use, if not set it will default to t0 version 1.5.5
	 terraform_version  = string



}
```
## Required Inputs

The following input variables are required:

### <a name="input_branch"></a> [branch](#input\_branch)

Description: GitHub branch to apply changes to

Type: `string`

### <a name="input_repository"></a> [repository](#input\_repository)

Description: Name of the repository, without the owner slug prefix

Type: `string`

### <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name)

Description: Name of the stack - should be unique in one account. A naming convention of <environment>-<project>-<module>-<region> is recommended.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_context_ids"></a> [context\_ids](#input\_context\_ids)

Description: List of Spacelift context IDs to attach to the stack

Type: `list(string)`

Default: `[]`

### <a name="input_description"></a> [description](#input\_description)

Description: Description of the stack

Type: `string`

Default: `"A stack managed by Terraform"`

### <a name="input_enable_admin_stack"></a> [enable\_admin\_stack](#input\_enable\_admin\_stack)

Description: Whether to enable administrative access to the stack to manage other Spacelift stacks and resources. Automically disables IAM integration.

Type: `bool`

Default: `false`

### <a name="input_enable_autodeploy"></a> [enable\_autodeploy](#input\_enable\_autodeploy)

Description: Whether to enable automatic apply of changes to the stack

Type: `bool`

Default: `false`

### <a name="input_enable_iam_integration"></a> [enable\_iam\_integration](#input\_enable\_iam\_integration)

Description: Whether to enable an IAM role to be created for the stack.

Type: `bool`

Default: `true`

### <a name="input_enable_protect_from_deletion"></a> [enable\_protect\_from\_deletion](#input\_enable\_protect\_from\_deletion)

Description: Whether to protect the stack from deletion. This value should only be changed if you understand the implications of doing so.

Type: `bool`

Default: `true`

### <a name="input_enable_state_management"></a> [enable\_state\_management](#input\_enable\_state\_management)

Description: Whether to enable state management for the stack. If disabled, the implementation of the module should define another remote backend such as S3.

Type: `bool`

Default: `false`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Stack scoped environment variables to set for the stack. These variables will be available to all Terraform runs for the stack. All variables will be prefixed automatically with TF\_VAR\_.

Type: `map(string)`

Default: `{}`

### <a name="input_iam_role_policy_arns"></a> [iam\_role\_policy\_arns](#input\_iam\_role\_policy\_arns)

Description: IAM role policy ARNs to attach to the stack's IAM role. The IAM role will be created if create\_iam\_role is true. The policies ARNs can either be ARNs of AWS managed policies or custom policies.

Type: `list(string)`

Default:

```json
[
  "arn:aws:iam::aws:policy/AdministratorAccess"
]
```

### <a name="input_labels"></a> [labels](#input\_labels)

Description: Labels to assign to the stack.

Type: `list(string)`

Default: `[]`

### <a name="input_path"></a> [path](#input\_path)

Description: Path to the root of the project

Type: `string`

Default: `null`

### <a name="input_policy_ids"></a> [policy\_ids](#input\_policy\_ids)

Description: List of Spacelift policy IDs to attach to the stack

Type: `list(string)`

Default: `[]`

### <a name="input_stack_dependencies"></a> [stack\_dependencies](#input\_stack\_dependencies)

Description: A map of stack ids that this stack depends on. The key is the stack id and the value is a map of environment variables that are defined by outputs of the stack. i.e { "stack-id" = { "vpc\_id" = "vpc\_id" } }. The input name is automatically prefixed with TF\_VAR\_.

Type: `map(any)`

Default: `{}`

### <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version)

Description: Terraform version to use, if not set it will default to t0 version 1.5.5

Type: `string`

Default: `"1.5.5"`
## Outputs

The following outputs are exported:

### <a name="output_dependency_mappings"></a> [dependency\_mappings](#output\_dependency\_mappings)

Description: n/a

### <a name="output_number_of_dependencies"></a> [number\_of\_dependencies](#output\_number\_of\_dependencies)

Description: n/a

### <a name="output_number_of_output_references"></a> [number\_of\_output\_references](#output\_number\_of\_output\_references)

Description: n/a

### <a name="output_stack_iam_role_arn"></a> [stack\_iam\_role\_arn](#output\_stack\_iam\_role\_arn)

Description: n/a

### <a name="output_stack_iam_role_id"></a> [stack\_iam\_role\_id](#output\_stack\_iam\_role\_id)

Description: n/a

### <a name="output_stack_iam_role_policy_arns"></a> [stack\_iam\_role\_policy\_arns](#output\_stack\_iam\_role\_policy\_arns)

Description: n/a

### <a name="output_stack_id"></a> [stack\_id](#output\_stack\_id)

Description: n/a
<!-- END_TF_DOCS -->