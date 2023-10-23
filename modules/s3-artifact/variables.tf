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

variable "replica_bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "full_lifecycle_management" {
  type        = bool
  description = "Whether or not to enable full lifecycle management on the S3 bucket. Defaults to ture."
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

variable "pimary_bucket_acl" {
  type        = string
  description = "The ACL option to apply to the primary S3 bucket."
  default     = "private"
}

variable "enable_storage_lifecycles" {
  type        = bool
  description = "Whether or not to enable full lifecycle management on the S3 bucket."
  default     = true
}

variable "lifecycle_versioning_id" {
  type        = string
  description = "The ID of the versioning lifecycle rule."
  default     = "expire-noncurrent-versions"
}

variable "lifecycle_transitioin_id" {
  type        = string
  description = "The ID of the transition lifecycle rule."
  default     = "downgrade-storage-class"
}

variable "transition_30_storage_class" {
  type        = string
  description = "The storage class to transition to after 30 days."
  default     = "STANDARD_IA"
}

variable "transition_90_storage_class" {
  type        = string
  description = "The storage class to transition to after 90 days."
  default     = "GLACIER"
}

variable "bucket_replication_configuration_rule_id" {
  type        = string
  description = "The ID of the replication configuration rule."
  default     = "bucket-replication-rule"
}

variable "replica_configuration_destination_storage_class" {
  type        = string
  description = "The default storage class for objects in the destination bucket. Valid values are STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE, or OUTPOSTS. Defaults to STANDARD."
  default     = "STANDARD"
}

variable "replica_configuration_status" {
  type        = string
  description = "The replication configuration status. Valid values are Enabled or Disabled."
  default     = "Enabled"
}
