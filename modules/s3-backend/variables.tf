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

variable "region" {
  description = "AWS region where the bucket should be provisioned to"
  type        = string
  default     = "us-east-1"
}

variable "sse_algorithm" {
  description = "Server side encryption algorithm for S3 bucket"
  type        = string
  default     = "AES256"
}

variable "environment" {
  description = "The environment type i.e (dev, staging, qa, prod)"
  type = string
  default = "staging"
  validation {
    condition = contains(["dev", "staging", "qa", "prod"], var.environment)
    error_message = "Environment must be either dev, staging, qa, or prod"
  }
}

variable "path" {
  description = "The path to organize the policy in IAM"
  type = string
  default = "/"
}
