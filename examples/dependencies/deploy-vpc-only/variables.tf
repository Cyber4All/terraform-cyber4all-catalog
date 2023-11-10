# --------------------------------------------------------------------

# REQUIRED PARAMETERS

# These values are required by the module and have no default values

# --------------------------------------------------------------------

# No required parameters at this time...


# --------------------------------------------------------------------

# OPTIONAL PARAMETERS

# These values are optional and have default values

# --------------------------------------------------------------------

variable "random_id" {
  description = "Random ID generated for the purpose of namespacing tests."
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region to provision resources to."
  type        = string
  default     = "us-east-1"
}
