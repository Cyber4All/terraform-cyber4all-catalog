variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "mike-testing-cause-suck-at-naming-things"
}

variable "enable_storage_class_transition" {
  type        = bool
  description = "Whether or not to enable full lifecycle management with both storage transitions on the S3 bucket. Defaults to false and is an opt-in feature since bucket versioning will always be enabled."
  default     = true
}
