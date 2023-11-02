variable "cluster_instance_ami" {
  type        = string
  description = "The AMI to run on each instance in the ECS cluster."
  default     = "ami-0e692fe1bae5ca24c"
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

variable "vpc_id" {
  description = "The ID of the VPC to deploy the ECS cluster to."
  type        = string
  default     = ""
}

variable "vpc_subnet_ids" {
  description = "The IDs of the subnets to deploy the ECS cluster to."
  type        = list(string)
  default     = []
}
