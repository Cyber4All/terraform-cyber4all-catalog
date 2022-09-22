########################################
# Required Vars
########################################
variable "project_name" {
  type = string
  description = "name that will be appended to all default names"
}

variable "launch_template_ami" {
  type = string
  description = "the ami image number for the ec2 instance to be launched"
}

variable "instance_type" {
  type = string
  description = "the type of instance to launch (e.g. t2.micro)"
}

variable "ingress_cidr_blocks" {
  type = list(string)
  description = "list of ingress cidr blocks for the security group to be created"
}

variable "egress_cidr_blocks" {
  type = list(string)
  description = "list of ingress cidr blocks for the security group to be created"
}

variable "ingress_rules" {
  type = list(string)
  description = "list of ingress rules for the security group to be created"
}

variable "egress_rules" {
  type = list(string)
  description = "list of egress rules for the security group to be created"
}

variable "public_subnets" {
  type = list(string)
  description = "the list of public subnets to create for the VPC"
}

variable "private_subnets" {
  type = list(string)
  description = "the list of private subnets to create for the VPC"
}

variable "asg_max_size" {
  type = number
  description = "maximum size of the autoscaling group"
}

variable "security_group_description" {
  type = string
  description = "the description for the security group to be created"
}

variable "vpc_id" {
  type = string
  description = "VPC id to create the cluster in"
}


########################################
# Optional vars
########################################

variable "asg_min_size" {
  type = number
  description = "minimum size of the autoscaling group"
  default     = 1
}

variable "launch_template_description" {
  type = string
  description = "description of the launch template"
  default     = ""
}

variable "iam_role_description" {
  type = string
  description = "the description for the iam role to be created"
  default     = ""
}

variable "avail_zones" {
  type = list(string)
  description = "the list of availability zones to create subnets in"
  default     = ["us-east-1a", "us-east-1b"]
}