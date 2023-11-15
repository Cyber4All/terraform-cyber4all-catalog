# -----------------------------------------------------------------------------
# MODULE PARAMETERS
#
# These values are expected to be set by the operator when calling the module
# -----------------------------------------------------------------------------


# --------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# These values are required by the module and have no default values
# --------------------------------------------------------------------

variable "branch" {
  description = "GitHub branch to apply changes to"
  type        = string
}

variable "stack_name" {
  description = "Name of the stack - should be unique in one account. A naming convention of <environment>-<project>-<module>-<region> is recommended."
  type        = string
}

variable "repository" {
  description = "Name of the repository, without the owner slug prefix"
  type        = string
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "context_ids" {
  description = "List of Spacelift context IDs to attach to the stack"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Description of the stack"
  type        = string
  default     = "A stack managed by Terraform"
}

variable "enable_admin_stack" {
  description = "Whether to enable administrative access to the stack to manage other Spacelift stacks and resources. Automically disables IAM integration."
  type        = bool
  default     = false
}

variable "enable_autodeploy" {
  description = "Whether to enable automatic apply of changes to the stack"
  type        = bool
  default     = false
}

variable "enable_iam_integration" {
  description = "Whether to enable an IAM role to be created for the stack."
  type        = bool
  default     = true
}

variable "enable_init_run" {
  description = "Whether to enable an initial tracked run when Spacelift stack is first created."
  type        = bool
  default     = false
}

variable "enable_protect_from_deletion" {
  description = "Whether to protect the stack from deletion. This value should only be changed if you understand the implications of doing so."
  type        = bool
  default     = true
}

variable "enable_state_management" {
  description = "Whether to enable state management for the stack. If disabled, the implementation of the module should define another remote backend such as S3."
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Stack scoped environment variables to set for the stack. These variables will be available to all Terraform runs for the stack. All variables will be prefixed automatically with TF_VAR_."
  type        = map(string)
  default     = {}
}

variable "iam_role_policy_arns" {
  description = "IAM role policy ARNs to attach to the stack's IAM role. The IAM role will be created if create_iam_role is true. The policies ARNs can either be ARNs of AWS managed policies or custom policies."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "labels" {
  description = "Labels to assign to the stack."
  type        = list(string)
  default     = []
}

variable "path" {
  description = "Path to the root of the project"
  type        = string
  default     = null
}

variable "policy_ids" {
  description = "List of Spacelift policy IDs to attach to the stack"
  type        = list(string)
  default     = []
}

variable "stack_dependencies" {
  description = "A map of stack ids that this stack depends on. The key is the stack id and the value is a map of environment variables that are defined by outputs of the stack. i.e { \"stack-id\" = { \"vpc_id\" = \"vpc_id\" } }. The input name is automatically prefixed with TF_VAR_."
  type        = map(any)
  default     = {}
}

variable "terraform_version" {
  description = "Terraform version to use, if not set it will default to t0 version 1.5.5"
  type        = string
  default     = "1.5.5"
}
