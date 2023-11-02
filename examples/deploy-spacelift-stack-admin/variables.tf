# -----------------------------------------------------

# ENVIRONMNENT VARIABLES

# Define these secrets as environment variables

# -----------------------------------------------------

# AWS_ACCESS_KEY_ID

# AWS_SECRET_ACCESS_KEY


# --------------------------------------------------------------------

# REQUIRED PARAMETERS

# These values are required by the module and have no default values

# --------------------------------------------------------------------


# --------------------------------------------------------------------

# OPTIONAL PARAMETERS

# These values are optional and have default values

# --------------------------------------------------------------------

variable "region" {
  description = "The AWS region to provision resources to."
  type        = string
  default     = "us-east-1"
}

variable "random_id" {
  description = "Random id generated for the purpose of testing"
  type        = string
  default     = ""
}
