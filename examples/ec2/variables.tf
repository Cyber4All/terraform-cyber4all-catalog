########################################
# Required Vars
########################################
variable "project_name" {
  description = "name that will be appended to all default names"
}

variable "launch_template_ami" {
  description = "the ami image number for the ec2 instance to be launched"
}

variable "instance_type" {
  description = "the type of instance to launch (e.g. t2.micro)"
}

variable "ingress_cidr_blocks" {
  description = "list of ingress cidr blocks for the security group to be created"
}

variable "ingress_rules" {
  description = "list of ingress rules for the security group to be created"
}

variable "egress_rules" {
  description = "list of egress rules for the security group to be created"
}

variable "public_subnets" {
  description = "the list of public subnets to create for the VPC"
}

variable "private_subnets" {
  description = "the list of private subnets to create for the VPC"
}

variable "asg_max_size" {
  description = "maximum size of the autoscaling group"
}



########################################
# Optional vars
########################################

variable "asg_name" {
  description = "Name for the autoscaling group"
  default     = "${project_name}-asg"
}
variable "launch_template_name" {
  description = "Name for the launch template that will be created"
  default     = "${project_name}-launch-template"
}
variable "cluster_name" {
  description = "the name of the cluster that is to be created"
  default = "${project_name}-cluster"
}

variable "iam_role_name" {
  description = "the name of the iam role to be created for the ASG"
  default = "${project_name}-iam-role"
}

variable "security_group_name" {
  description = "the name of the security group to be created"
  default = "${project_name}-sg"
}

variable "asg_min_size" {
  description = "minimum size of the autoscaling group"
  default     = 1
}

variable "launch_template_description" {
  description = "description of the launch template"
  default = ""
}

variable "iam_role_description" {
  description = "the description for the iam role to be created"
  default = ""
}

variable "security_group_description" {
  description = "the description for the security group to be created"
  default = ""
}

variable "avail_zones" {
  description = "the list of availability zones to create subnets in"
  default = ["us-east-1a", "us-east-1b"]
}