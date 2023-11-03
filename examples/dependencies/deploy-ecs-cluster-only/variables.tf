# --------------------------------------------------------------------

# REQUIRED PARAMETERS

# These values are required by the module and have no default values

# --------------------------------------------------------------------

# No required parameters at this time...


# --------------------------------------------------------------------

# OPTIONAL PARAMETERS

# These values are optional and have default values

# --------------------------------------------------------------------

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
  description = "The ID of the VPC to deploy the ECS cluster into."
  type        = string
  default     = ""
}

variable "vpc_subnet_ids" {
  description = "The IDs of the subnets to deploy the ECS cluster into."
  type        = list(string)
  default     = []
}
