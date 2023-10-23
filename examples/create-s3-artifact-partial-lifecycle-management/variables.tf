variable "primary_bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "example-primary-static-bucket"
}

variable "replica_bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "example-replica-static-bucket"
}
