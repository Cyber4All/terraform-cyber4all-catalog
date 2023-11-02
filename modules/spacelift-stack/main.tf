# -------------------------------------------------------------------------------------
# CREATE SPACELIFT STACKS FOR (GIT)-FLOW 
# 
# These templates deploys a Spacelift stack that can be used to manage your terraform
# infrastructure using terraform or terragrunt. The module includes the following:
# - Spacelift stack
# - AWS IAM role for Spacelift
# -------------------------------------------------------------------------------------

# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.6.0"
    }
  }
}


# -------------------------------------------
# CREATE THE SPACELIFT STACK
# -------------------------------------------

resource "spacelift_stack" "this" {
  name        = var.stack_name
  description = var.description
  labels      = var.labels

  repository   = var.repository
  branch       = var.branch
  project_root = var.project_root

  administrative        = var.enable_admin_stack
  autodeploy            = var.enable_autodeploy
  manage_state          = var.enable_state_management
  protect_from_deletion = var.enable_protect_from_deletion

  terraform_smart_sanitization = true
  terraform_version            = var.terraform_version

  # This can be transitioned to OpenToFu at a later time
  terraform_workflow_tool = "TERRAFORM_FOSS"
}


# ---------------------------------------------------
# DEFINE THE SPACELIFT STACK ENVIRONMENT VARIABLES
# ---------------------------------------------------

locals {
  environment_variables = [for k, v in var.environment_variables : {
    name  = k
    value = v
  }]
}

resource "spacelift_environment_variable" "this" {
  count = length(keys(var.environment_variables))

  stack_id = spacelift_stack.this.id

  name       = "TF_VAR_${lookup(local.environment_variables[count.index], "name", null)}"
  value      = lookup(local.environment_variables[count.index], "value", null)
  write_only = true
}


# ---------------------------------------------------
# ATTACH THE SPACELIFT CONTEXT TO THE STACK
# ---------------------------------------------------

resource "spacelift_context_attachment" "this" {
  count = length(var.context_ids)

  context_id = var.context_ids[count.index]
  stack_id   = spacelift_stack.this.id

  priority = count.index
}


# ---------------------------------------------------
# ATTACH THE SPACELIFT POLICIES TO THE STACK
# ---------------------------------------------------

resource "spacelift_policy_attachment" "this" {
  count = length(var.policy_ids)

  policy_id = var.policy_ids[count.index]
  stack_id  = spacelift_stack.this.id
}

# ---------------------------------------------------
# CREATE STACK DESTRUCTOR
# ---------------------------------------------------

resource "spacelift_stack_destructor" "this" {
  depends_on = [
    spacelift_stack.this,
    spacelift_environment_variable.this,
    spacelift_policy_attachment.this,
    spacelift_context_attachment.this,

    # Adding the following dependencies to ensure that the stack is destroyed first before the IAM role
    # and its attachments are destroyed.
    aws_iam_role.this,
    aws_iam_role_policy_attachment.this,
    spacelift_aws_integration.this,
    spacelift_aws_integration_attachment.this,
    data.spacelift_aws_integration_attachment_external_id.this
  ]

  stack_id = spacelift_stack.this.id
}

# ---------------------------------------------------
# ADD STACK DEPENDENCIES
# ---------------------------------------------------

locals {
  # map stack depdency id from spacelift_stack_dependency to the mappings defined in the stack_dependencies variable
  dependency_mappings = flatten([
    # iterate over each stack dependency
    for stack_dependency_resource in spacelift_stack_dependency.this : [

      # iterate over each mapping defined in the stack_dependencies variable
      for depends_on_stack_id, mapping in var.stack_dependencies : [

        # Create a mapping of the stack_dependency_id to the variable mappings defined in the stack_dependencies variable
        # only if the depends on stack id matches the id defined in the spacelift_stack_dependency resource
        for input_name, output_name in mapping :
        depends_on_stack_id == stack_dependency_resource.depends_on_stack_id ? {
          stack_dependency_id = stack_dependency_resource.id
          input_name          = "TF_VAR_${input_name}"
          output_name         = output_name
        } : null
      ]
    ]
  ])

  # list of stack dependency ids
  depends_on_stack_ids = keys(var.stack_dependencies)

  number_of_dependencies = length(local.depends_on_stack_ids)
  number_of_references   = length(local.dependency_mappings)
}

resource "spacelift_stack_dependency" "this" {
  count = local.number_of_dependencies

  stack_id            = spacelift_stack.this.id
  depends_on_stack_id = local.depends_on_stack_ids[count.index]
}

resource "spacelift_stack_dependency_reference" "this" {
  count = local.number_of_references

  stack_dependency_id = local.dependency_mappings[count.index].stack_dependency_id

  input_name  = local.dependency_mappings[count.index].input_name
  output_name = local.dependency_mappings[count.index].output_name
}


# ---------------------------------------------------------

# THE FOLLOWING SECTION CONFIGURES THE IAM ROLE

# THAT THE SPACELIFT STACK WILL USE TO MANAGE

# YOUR AWS RESOURCES.

# ---------------------------------------------------------


# -------------------------------------------
# CONVIENIENCE VARIABLES
# -------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  iam_role_name = "${var.stack_name}-stack-role"

  iam_role_path = "/spacelift/"

  iam_role_arn = "arn:aws:iam::${local.account_id}:role${local.iam_role_path}${local.iam_role_name}"
}


# ---------------------------------------------------
# CREATE THE AWS IAM ROLE FOR SPACELIFT INTEGRATION
# ---------------------------------------------------

resource "spacelift_aws_integration" "this" {
  count = var.create_iam_role ? 1 : 0

  name = local.iam_role_name

  # We need to set this manually rather than referencing the role to avoid a circular dependency
  # between the role and the integration.
  role_arn                       = local.iam_role_arn
  generate_credentials_in_worker = false
}

data "spacelift_aws_integration_attachment_external_id" "this" {
  count = var.create_iam_role ? 1 : 0

  integration_id = spacelift_aws_integration.this[0].id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true
}

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name = local.iam_role_name
  path = local.iam_role_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      jsondecode(data.spacelift_aws_integration_attachment_external_id.this[0].assume_role_policy_statement),
    ]
  })
}

# ---------------------------------------------------
# ATTACH THE IAM POLICIES TO THE SPACELIFT IAM ROLE
# ---------------------------------------------------

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create_iam_role ? length(var.iam_role_policy_arns) : 0

  role       = aws_iam_role.this[0].id
  policy_arn = var.iam_role_policy_arns[count.index]
}

# ---------------------------------------------------
# ATTACH THE AWS IAM ROLE TO THE SPACELIFT STACK
# ---------------------------------------------------

resource "spacelift_aws_integration_attachment" "this" {
  count = var.create_iam_role ? 1 : 0

  integration_id = spacelift_aws_integration.this[0].id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true

  # The role needs to exist before we attach since we test role assumption during attachment.
  depends_on = [
    aws_iam_role.this,
  ]
}