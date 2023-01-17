# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "bucket_name" {
  description = "The name of the backend bucket"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the dynamodb table"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "sse_algorithm" {
  description = "Server side encryption algorithm for S3 bucket"
  type        = string
  default     = "AES256"
}
