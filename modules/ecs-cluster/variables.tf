# -----------------------------------------------------------------------------
# MODULE PARAMETERS
#
# These values are expected to be set by the operator when calling the module
# -----------------------------------------------------------------------------


# --------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# These values are required by the module and have no default values
# --------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster."
}

variable "cluster_instance_ami" {
  type        = string
  description = "The AMI to run on each instance in the ECS cluster."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in which the ECS cluster should be launched."
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets in which to deploy the ECS cluster instances."
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "autoscaling_sns_topic_arns" {
  type        = list(string)
  description = "The ARNs of SNS topics where failed Autoscaling notifications should be sent to."
  default     = []
}

variable "autoscaling_termination_protection" {
  type        = bool
  description = "Protect EC2 instances running ECS tasks from being terminated due to scale in (spot instances do not support lifecycle modifications). Note that the behavior of termination protection differs between clusters with capacity providers and clusters without. When capacity providers is turned on and this flag is true, only instances that have 0 ECS tasks running will be scaled in, regardless of capacity_provider_target. If capacity providers is turned off and this flag is true, this will prevent ANY instances from being scaled in."
  default     = true
}

variable "capacity_provider_max_scale_step" {
  type        = number
  description = "Maximum step adjustment size to the ASG's desired instance count. A number between 1 and 10000. It is better to overestimate this value."
  default     = 2
}

variable "capacity_provider_min_scale_step" {
  type        = number
  description = "Minimum step adjustment size to the ASG's desired instance count. A number between 1 and 10000. It is better to underestimate this value."
  default     = 1
}

variable "capacity_provider_target" {
  type        = number
  description = "Target cluster utilization for the ASG capacity provider; a number from 1 to 100. This number influences when scale out happens, and when instances should be scaled in. For example, a setting of 90 means that new instances will be provisioned when all instances are at 90% utilization, while instances that are only 10% utilized (CPU and Memory usage from tasks = 10%) will be scaled in."
  default     = 75
}

variable "cluster_ingress_access_ports" {
  type        = list(number)
  description = "Specify a list of ECS Cluster TCP ports which should be made accessible through ingress traffic."
  default     = []
}

variable "cluster_instance_type" {
  type        = string
  description = "The size of the EC2 instance."
  default     = "t2.micro"
}

variable "cluster_max_size" {
  type        = number
  description = "The maximum number of instances to run in the ECS cluster."
  default     = 3
}

variable "cluster_min_size" {
  type        = number
  description = "The minimum number of instances to run in the ECS cluster"
  default     = 1
}
