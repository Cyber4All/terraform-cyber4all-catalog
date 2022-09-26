########################################
# Required Vars
########################################
variable "project_name" {
  type        = string
  description = "name that will be appended to all default names"
}
# asg
variable "launch_template_ami" {
  type        = string
  description = "the ami image number for the ec2 instance to be launched"
}

variable "instance_type" {
  type        = string
  description = "the type of instance to launch (e.g. t2.micro)"
}

variable "public_subnets" {
  type        = list(string)
  description = "the list of public subnets from the vpc"
}

variable "private_subnets" {
  type        = list(string)
  description = "the list of private subnets from the VPC"
}

variable "asg_max_size" {
  type        = number
  description = "maximum size of the autoscaling group"
}

variable "vpc_id" {
  type        = string
  description = "VPC id to create the cluster in"
}

variable "security_group_ids" {
  type        = list(string)
  description = "list of security group ids to associate with the autoscaling group"
}

variable "autoscaling_capacity_providers" {
  type = map(object({
    auto_scaling_group_arn         = string
    managed_termination_protection = string

    managed_scaling = {
      maximum_scaling_step_size = number
      minimum_scaling_step_size = number
      status                    = string
      target_capacity           = number
    }
  }))
}
########################################
# Optional vars
########################################

variable "asg_min_size" {
  type        = number
  description = "minimum size of the autoscaling group"
  default     = 1
}

variable "launch_template_description" {
  type        = string
  description = "description of the launch template"
  default     = ""
}

variable "iam_role_description" {
  type        = string
  description = "the description for the iam role to be created"
  default     = ""
}

variable "avail_zones" {
  type        = list(string)
  description = "the list of availability zones to create subnets in"
  default     = ["us-east-1a", "us-east-1b"]
}