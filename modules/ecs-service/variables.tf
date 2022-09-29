# --------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------

variable "name" {
  description = "The name of the service"
  type        = string
}

variable "task_def_arn" {
  description = "The ARN of the task definition that the service will run"
  type        = string
}

variable "cluster_arn" {
  description = "The ARN of the cluster where the service will be located"
  type        = string
}

variable "num_tasks" {
  description = "The number of instances of the given task definition to place and run"
  type        = number
}

variable "public_subnets" {
  description = "The list of public subnets from the vpc"
  type        = list(string)
}

variable "private_subnets" {
  description = "The list of private subnets from the vpc"
  type        = list(string)
}

variable "security_group_id" {
  description = "The id of the security group created"
  type        = string
}

# --------------------------------------------------------
# OPTIONAL PARAMETERS
# All the parameters below are optional.
# These parameters have reasonable defaults.
# --------------------------------------------------------