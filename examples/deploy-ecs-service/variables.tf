variable "cluster_instance_ami" {
  type        = string
  description = "The AMI to run on each instance in the ECS cluster."
  default     = "ami-0e692fe1bae5ca24c"
}

variable "external_container_image" {
  type        = string
  description = "The docker image that will be used in the task. The image is bootstrapped meaning it is only used for initialization, previous applies should unset this variable to allow for external application deployments to persist."
  default     = "cyber4all/mock-container-image:latest"
}

variable "random_id" {
  description = "Random id generated for the purpose of testing"
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region to provision resources to."
  type        = string
  default     = "us-east-1"
}
