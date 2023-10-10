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

variable "container_image" {
  type        = string
  description = "The docker image to use for the ECS task. If this value is not set, it will try and pull the currently deployed container image. This allows for external application deployments to be managed outside of Terraform."
  default     = ""
}

variable "container_port" {
  type        = number
  description = "The port that the container listens on."
  default     = null
}

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
  description = "The number of instances of the ECS service or scheduled task to run across the ECS cluster."
  default     = 1
  validation {
    condition     = var.desired_number_of_tasks >= 1
    error_message = "The desired_number_of_tasks must be greater than or equal to 1."
  }
}

variable "docker_credentials_secret_arn" {
  type        = string
  description = "The ARN of the AWS Secrets Manager secret containing the Docker credentials."
  default     = ""
  validation {
    condition     = var.docker_credentials_secret_arn == "" || length(split(":", var.docker_credentials_secret_arn)) == 7
    error_message = "The docker_credentials_secret_arn must be a valid ARN."
  }
}

variable "enable_container_logs" {
  type        = bool
  description = "Enable container logging to CloudWatch Logs."
  default     = true
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
  default     = true
}

variable "enable_service_connect" {
  type        = bool
  description = "Enable service discovery for the ECS service."
  default     = true
}

variable "environment_variables" {
  type        = map(string)
  description = "A map of environment variables to pass to the ECS task."
  default     = {}
}

variable "lb_listener_arn" {
  type        = string
  description = "The load balancer listener arn to attach the ECS service to. This value is required when enable_load_balancer is true."
  default     = ""
}

variable "lb_target_group_vpc_id" {
  type        = string
  description = "The VPC id to deploy the ECS service's load balancer traget group into. Required when enable_load_balancer is true."
  default     = ""
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

variable "scheduled_task_assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ECS task."
  default     = true
}

variable "scheduled_task_cron_expression" {
  type        = string
  description = "The cron expression to use for the scheduled task. If create scheduled task is true and no event pattern is provided, then the cron is expected."
  default     = ""
}

variable "scheduled_task_event_pattern" {
  type        = any
  description = "The event pattern to use for the scheduled task. If create scheduled task is true and no cron expression is provided, then the event pattern is expected."
  default     = null
}

variable "scheduled_task_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with the ECS task. A permissive default security will be used if not specified."
  default     = []
}

variable "scheduled_task_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to associate with the ECS task. This value is required when create_scheduled_task is true."
  default     = []
}

variable "secrets" {
  type        = map(string)
  description = "A map of secrets to pass to the ECS task. These are environment variables that are sensitive and should not be stored in plain text. Instead they are stored in AWS Secrets Manager and injected at runtime into the ECS task."
  default     = {}
}
