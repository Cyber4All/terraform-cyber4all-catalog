# -----------------------------------------------------------------------------
# MODULE PARAMETERS
#
# These values are expected to be set by the operator when calling the
# S3-Artifact smodule
# -----------------------------------------------------------------------------


# --------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# These values are required by the module and have no default values
# --------------------------------------------------------------------

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "enable_replica" {
  type        = bool
  description = "Whether or not to create a replica bucket in a different region. Defaults to true."
  default     = true
}

variable "enable_storage_class_transition" {
  type        = bool
  description = "Whether or not to enable full lifecycle management with both storage transitions on the S3 bucket. Defaults to false and is an opt-in feature since bucket versioning will always be enabled."
  default     = false
}

variable "enable_public_access" {
  type        = bool
  description = "Whether or not to enable public access to the S3 bucket. Defaults to false."
  default     = false
}

variable "primary_region" {
  type        = string
  description = "The AWS region in which to create the S3 bucket."
  default     = "us-east-1"
}

variable "replica_region" {
  type        = string
  description = "The AWS region in which to create the replica S3 bucket."
  default     = "us-east-2"
}
