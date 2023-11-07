variable "mongodb_role_arn" {
  type        = string
  description = "The ARN of the IAM role to assume when interacting with MongoDB Atlas"
}

variable "random_id" {
  type        = string
  description = "A random ID to append to the cluster name"
  default     = ""
}
