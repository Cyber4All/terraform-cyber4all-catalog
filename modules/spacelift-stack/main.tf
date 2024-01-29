# -------------------------------------------------------------------------------------
# CREATE SPACELIFT STACKS FOR (GIT)-FLOW 
# 
# These templates deploys a Spacelift stack that can be used to manage your terraform
# infrastructure using terraform or terragrunt. The module includes the following:
# - Spacelift stack
# -------------------------------------------------------------------------------------

# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.6.0"
    }
  }
}


# -------------------------------------------
# CREATE THE SPACELIFT STACK
# -------------------------------------------

locals {
  admin_label                 = var.enable_admin_stack ? "Admin" : null
  autodeploy_label            = var.enable_autodeploy ? "Autodeploy" : null
  state_management_label      = var.enable_state_management ? "State Managed" : null
  protect_from_deletion_label = var.enable_protect_from_deletion ? "Protected from Deletion" : null

  # Adds additional labels to the stack for filtering purposes
  labels = concat(var.labels, compact([
    local.admin_label,
    local.autodeploy_label,
    local.state_management_label,
    local.protect_from_deletion_label,
  ]))
}

resource "spacelift_stack" "this" {
  name        = var.stack_name
  description = var.description
  labels      = local.labels

  repository   = var.repository
  branch       = var.branch
  project_root = var.path

  administrative        = var.enable_admin_stack
  autodeploy            = var.enable_autodeploy
  manage_state          = var.enable_state_management
  protect_from_deletion = var.enable_protect_from_deletion

  terraform_smart_sanitization = true
  terraform_version            = var.terraform_version

  # This can be transitioned to OpenToFu at a later time
  terraform_workflow_tool = "TERRAFORM_FOSS"

  depends_on = [
    data.spacelift_aws_integration.this
  ]
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
  write_only = false
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
    # Adding the following dependencies to ensure that the tracked resources are
    # destroyed first before the following are destroyed.
    spacelift_aws_integration_attachment.this,
    spacelift_context_attachment.this,
    spacelift_environment_variable.this,
    spacelift_policy_attachment.this,
    spacelift_stack.this,
  ]

  stack_id = spacelift_stack.this.id
}

# ---------------------------------------------------
# ADD STACK DEPENDENCIES
# ---------------------------------------------------

resource "spacelift_stack_dependency" "this" {
  count = length(var.stack_dependencies)

  stack_id            = spacelift_stack.this.id
  depends_on_stack_id = var.stack_dependencies[count.index]
}


# ---------------------------------------------------
# RUN THE STACK IF ADMIN STACK IS ENABLED
# ---------------------------------------------------

resource "spacelift_run" "this" {
  count = var.enable_admin_stack || var.enable_init_run ? 1 : 0

  stack_id = spacelift_stack.this.id

  keepers = {
    repository = spacelift_stack.this.repository
    branch     = spacelift_stack.this.branch
    path       = spacelift_stack.this.project_root
  }

  depends_on = [
    # Enforce that the stack and its reosurces are created before
    # running the stack
    spacelift_stack_destructor.this,
  ]
}


# ---------------------------------------------------------

# THE FOLLOWING SECTION CONFIGURES THE INTEGRATION

# THAT THE SPACELIFT STACK WILL USE TO MANAGE

# YOUR AWS RESOURCES.

# ---------------------------------------------------------

# ---------------------------------------------------
# CREATE THE AWS IAM ROLE FOR SPACELIFT INTEGRATION
# ---------------------------------------------------

data "spacelift_aws_integration" "this" {
  count = var.spacelift_integration_name != "" ? 1 : 0

  name = var.spacelift_integration_name
}

# ---------------------------------------------------
# ATTACH THE AWS IAM ROLE TO THE SPACELIFT STACK
# ---------------------------------------------------

resource "spacelift_aws_integration_attachment" "this" {
  count = var.spacelift_integration_name != "" ? 1 : 0

  integration_id = data.spacelift_aws_integration.this[0].id
  stack_id       = spacelift_stack.this.id
}
