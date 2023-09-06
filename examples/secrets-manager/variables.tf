variable "region" {
  description = "The AWS region to provision resources to."
  type        = string
  default     = "us-east-1"
}

variable "random_id" {
  description = "Random id generated for the purpose of testing"
  type        = string
  default     = ""
}

variable "secret_key" {
  description = "The key of the secret"
  type        = string
  default     = "key"
}

variable "secret_value" {
  description = "The value of the secret"
  type        = string
  default     = "value"
}
