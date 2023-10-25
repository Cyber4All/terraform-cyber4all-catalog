variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "mike-partial-lifecycle-management"
}

variable "partial_lifecycle_management" {
  type        = bool
  description = "Toggle for partial lifecycle management for only object versions on the S3 bucket."
  default     = false
}
