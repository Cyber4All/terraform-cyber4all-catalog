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

variable "project_name" {
  description = "Name of the project as it appears in Atlas to deploy the cluster into."
  type        = string
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "authorized_iam_users" {
  description = "Create a map of AWS IAM users to assign an admin, readWrite, or read database role to the project's databases."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.cluster_authorized_iam_users : anytrue([for role in ["admin", "readWrite", "read"] : strcontains(v, role)])])
    error_message = "A database role must be one of the following: admin, readWrite, read."
  }
}

variable "authorized_iam_roles" {
  description = "Create a map of AWS IAM roles to assign an admin, readWrite, or read database role to the cluster's databases."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.cluster_authorized_iam_roles : anytrue([for role in ["admin", "readWrite", "read"] : strcontains(v, role)])])
    error_message = "A database role must be one of the following: admin, readWrite, read."
  }
}

variable "enable_vpc_peering" {
  description = "Set to true to enable a peering connection with an existing VPC."
  type        = bool
  default     = false
}

variable "peering_route_table_ids" {
  description = "The route table IDs of the VPC to peer with. Each route table should belong to a unique VPC."
  type        = list(string)
  default     = []
}

variable "peering_cidr_block" {
  description = "The CIDR block of the VPC to peer with."
  type        = string
  default     = ""
}
