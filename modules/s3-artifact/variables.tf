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

variable "primary_bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "enable_lifecycle_management" {
  type        = bool
  description = "Whether or not to enable full lifecycle management with storage transitions and object sversions on the S3 bucket. Defaults to ture."
  default     = true
}

variable "priamry_region" {
  type        = string
  description = "The AWS region in which to create the S3 bucket."
  default     = "us-east-1"
}

variable "replica_region" {
  type        = string
  description = "The AWS region in which to create the S3 bucket."
  default     = "us-east-2"
}

variable "enable_bucket_versioning" {
  type        = bool
  description = "Whether or not to enable versioning on the S3 bucket."
  default     = true
}
