variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "cyber4all-public-artifact-bucket"
}

variable "enable_public_access" {
  type        = bool
  description = "Whether or not to enable public access to the S3 bucket. Defaults to false."
  default     = true
}
