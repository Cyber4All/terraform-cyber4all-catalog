# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Name that will prepend all resources."
}

# ----------------------------------------------------
# auto scaling group parameters
# ----------------------------------------------------
variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside."
}

# ----------------------------------------------------
# security group parameters
# ----------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where to create security group."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------
# ecs cluster parameters
# ----------------------------------------------------
variable "log_group_name" {
  type        = string
  description = "The name of the CloudWatch log group to send logs to."
  default     = null
}

# ----------------------------------------------------
# auto scaling group parameters
# ----------------------------------------------------

# launch template
variable "launch_template_description" {
  type        = string
  description = "Description of the launch template."
  default     = "Launch template managed by Terraform"
}

variable "ami_id" {
  type        = string
  description = "The AMI from which to launch the instance. (default: Amazon Linux AMI amzn-ami-2018.03.20220831 x86_64 ECS HVM GP2, deprecated: Fri Aug 30 2024 20:24:19 GMT-0400)"
  default     = "ami-06e07b42f153830d8"
}

variable "instance_type" {
  type        = string
  description = "The type of the instance. If present then `instance_requirements` cannot be present."
  default     = "t2.micro"
}

variable "block_device_mappings" {
  type        = list(any)
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI."
  default     = []
}

# auto scaling group
variable "min_size" {
  type        = number
  description = "The minimum size of the autoscaling group."
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The maximum size of the autoscaling group."
  default     = 1
}

variable "desired_capacity" {
  type        = number
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group."
  default     = 1
}

variable "enabled_metrics" {
  type        = list(string)
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`."
  default     = ["GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"]
}

variable "capacity_rebalance" {
  type        = bool
  description = "Indicates whether capacity rebalance is enabled."
  default     = true
}

# iam role
variable "iam_role_description" {
  type        = string
  description = "Description of the role."
  default     = "IAM Role managed by Terraform"
}

variable "iam_role_policies" {
  type        = map(string)
  description = "IAM policies to attach to the IAM role."
  default = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

# ----------------------------------------------------
# security group parameters
# ----------------------------------------------------
variable "sg_description" {
  type        = string
  description = "Description of security group."
  default     = "Security Group managed by Terraform"
}

variable "ingress_rules" {
  type        = list(string)
  description = "List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf)."
  default     = []
}

variable "egress_rules" {
  type        = list(string)
  description = "List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf)."
  default     = []
}

variable "ingress_with_cidr_blocks" {
  type        = list(map(string))
  description = "List of ingress rules to create where 'cidr_blocks' is used."
  default     = []
}

variable "egress_with_cidr_blocks" {
  type        = list(map(string))
  description = "List of egress rules to create where 'cidr_blocks' is used."
  default     = []
}
