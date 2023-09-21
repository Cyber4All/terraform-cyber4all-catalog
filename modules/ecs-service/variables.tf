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

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster to deploy the ECS service onto."
}

variable "ecs_service_name" {
  type        = string
  description = "The name of the ECS service to create."
}

# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "cpu_utilization_threshold" {
  type        = number
  description = "Percentage for the target tracking scaling threshold for the ECS Service average CPU utiliziation."
  default     = 50
}

variable "create_scheduled_task" {
  type        = bool
  description = "The ECS task should be deployed as a scheduled task rather than a managed ECS service."
  default     = false
}

variable "desired_number_of_tasks" {
  type        = number
  description = "The number of instances of the ECS service to run across the ECS cluster."
  default     = 1
  validation {
    condition     = var.desired_number_of_tasks >= 1
    error_message = "The desired_number_of_tasks must be greater than or equal to 1."
  }
}

variable "enable_container_logs" {
  type        = bool
  description = "Enable container logging to CloudWatch Logs."
  default     = false
}

variable "enable_deployment_rollback" {
  type        = bool
  description = "Enable rollback of a FAILED deployment if a service cannot reach a steady state."
  default     = true
}

variable "enable_load_balancer" {
  type        = bool
  description = "Enable a load balancer to create an ALB target for the ECS service that is attached to an existing ALB."
  default     = false
}

variable "enable_service_auto_scaling" {
  type        = bool
  description = "Enable auto scaling of the ECS service."
  default     = false
}

variable "enable_service_connect" {
  type        = bool
  description = "Enable service discovery for the ECS service."
  default     = false
}

variable "max_number_of_tasks" {
  type        = number
  description = "The maximum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale beyond this number."
  default     = 4
}

variable "memory_utilization_threshold" {
  type        = number
  description = "Percentage for the target tracking scaling threshold for the ECS Service average memory utiliziation."
  default     = 50
}

variable "min_number_of_tasks" {
  type        = number
  description = "The minimum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale below this number."
  default     = 1
}
