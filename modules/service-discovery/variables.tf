# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  type = string
  description = "The name of the namespace."
}

variable "vpc_id" {
  type = string
  description = "The ID of VPC that you want to associate the namespace with."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  type    = string
  desdescription = "The description that you specify for the namespace when you create it."
  default     = "Private DNS Namespace Managed by Terraform"
}
