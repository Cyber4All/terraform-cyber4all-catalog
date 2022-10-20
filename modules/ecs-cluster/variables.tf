########################################
# Required Vars
########################################
variable "project_name" {
  type        = string
  description = "name that will be appended to all default names"
}

variable "launch_template_ami" {
  type        = string
  description = "the ami image number for the ec2 instance to be launched"
}

variable "instance_type" {
  type        = string
  description = "the type of instance to launch (e.g. t2.micro)"
}

variable "asg_max_size" {
  type        = number
  description = "maximum size of the autoscaling group"
}

variable "vpc_id" {
  type        = string
  description = "VPC id to create the cluster in"
}

########################################
# Optional vars
########################################

variable "cluster_logging" {
  type = bool
  description = "Set to True to enable logging to cloud watch (cloud watch log-group must exist already)"
  default = false
}

variable "cloud_watch_log_group_name" {
  type = string
  description = "Name of the cloud watch log group (required when cluster_logging == true)"
  default = null
}

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

variable "subnets" {
  type        = list(string)
  description = "the list of subnets from the vpc to run the EC2 instances in"
  default     = []
}

variable "ingress_with_cidr_blocks" {
  type        = list(map(string))
  description = "list of ingress cidr blocks for the security group to be created"
  default     = []
}

variable "egress_with_cidr_blocks" {
  type        = list(map(string))
  description = "list of egress cidr blocks for the security group to be created"
  default     = []
}

variable "security_group_description" {
  type        = string
  description = "the description of the security group to create"
  default     = "default security group description"
}

variable "block_device_mappings" {
  type        = list(any)
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  default     = []
}

variable "capacity_rebalance" {
  type        = bool
  description = "Indicates whether capacity rebalance is enabled"
  default     = true
}

variable "desired_capacity" {
  type        = number
  description = "desired capacity"
  default     = 2
}

variable "iam_instance_profile_name" {
  type        = string
  description = "name for the IAM instance profile"
  default     = ""
}