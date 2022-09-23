########################################
# Required Vars
########################################
variable "project_name" {
  type        = string
  description = "name that will be appended to all default names"
}

variable "autoscaling_group_arn" {
  type        = string
  description = "arn of the autoscaling group to assign to the cluster"
}


