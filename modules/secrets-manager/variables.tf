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

variable "secrets" {
  type = list(object({
    name        = string
    description = optional(string)
    environment = list(object({
      name  = string
      value = string
    }))
  }))
  description = "List of secrets that can be used to maintain the secret and its environment variables managed by the secret."
}
