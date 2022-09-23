########################################
# Required Vars
########################################
variable "project_name" {
  type        = string
  description = "name that will be appended to all default names"
}
# asg

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
