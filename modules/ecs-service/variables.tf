# --------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------

variable "name" {
  description = "The name of the service"
  type        = string
}

variable "task_def" {
  description = "The ARN or family and revision of the task definition that the service will run"
  type        = string
}

variable "cluster_arn" {
  description = "The ARN of the cluster where the service will be located"
  type        = string
}

variable "num_tasks" {
  description = "The number of instances of the given task definition to place and run"
  type        = number
}

variable "public_subnets" {
  description = "The list of public subnets from the vpc"
  type        = list(string)
}

variable "private_subnets" {
  description = "The list of private subnets from the vpc"
  type        = list(string)
}

variable "security_group_id" {
  description = "The id of the security group created"
  type        = string
}

# --------------------------------------------------------
# OPTIONAL PARAMETERS
# All the parameters below are optional.
# These parameters have reasonable defaults.
# --------------------------------------------------------

variable "capacity_provider_base" {
  description = "Minimum number of tasks to run on the capacity provider"
  type = number
  default = 1
}

variable "capacity_provider_weight" {
  description = "Relative percent of number of launched tasks that use capacity provider"
  type = number
  default = 1
}

variable "capacity_provider_name" {
  description = "Short name for the capacity provider"
  type = string
  default = "example-capacity-provider"
}

variable "deployment_controller_type" {
  description = "Type of deployment controller"
  type = string # "CODE_DEPLOY" | "ECS" | "EXTERNAL" |
  default = "ECS"
}

variable "deployment_max_percent" {
  description = "Percent ceiling limit on num_tasks running on a service"
  type = number # percent = number / 100
  default = 100
}

variable "deployment_min_healthy_percent" {
  description = "Base percent of healthy tasks to be run on a service"
  type = number
  default = 10
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether or not to use ECS managed tags for tasks"
  type = bool
  default = false
}

variable "enable_execute_command" {
  description = "Specifies whether or not to use ECS Exec for tasks"
  type = bool
  default = false
}

variable "force_new_deployment" {
  description = "Specifies whether or not to force a new task deployment of the service. Typically used for updates"
  type = bool
  default = false
}

variable "health_check_grace_period_seconds" {
  description = "Time in seconds to wait until load balancer performs health checks on new tasks"
  type = number
  default = 0
}

variable "iam_role" {
  description = "Name or ARN of the IAM role"
  type = string
  default = null
}

variable "launch_type" {
  description = "Service launch type"
  type = string # "EC2" | "FARGATE" | "EXTERNAL"
  default = "EC2"
}

variable "load_balancer_target_group_arn" {
  description = "ARN of the load balancer"
  type = string
  default = null
}

variable "load_balancer_container_name" {
  description = "The name of the container to associate with load balancer"
  type = string
  default = null
}

variable "load_balancer_container_port" {
  description = "The port of the container to associate with load balancer"
  type = string
  default = null
}

variable "ordered_placement_strategy_type" {
  description = "Type of placement strategy"
  type = string # "binpack" | "random" | "spread"
  default = "random"
}

variable "ordered_placement_strategy_field" {
  description = "Describes how to use the type of placement strategy"
  type = any
  default = null
}

variable "placement_constraints_type" {
  description = "Type of placement constraint"
  type = string # "memberOf" | "distinctInstance"
  default = null
}

variable "placement_constraints_expression" {
  description = "Cluster Query Language expression to apply the constraint"
  type = string
  default = null
}

variable "propagate_tags" {
  description = "Specifies whether to propagate tags from task def or the service to the tasks"
  type = string # "SERVICE" | "TASK_DEFINITION"
  default = null
}

variable "scheduling_strategy" {
  description = "Service's scheduling strategy"
  type = string # "REPLICA" | "DAEMON"
  default = null
}

variable "service_registries_arn" {
  description = "ARN of the service registry"
  type = string
  default = null
}

variable "service_registries_port" {
  description = "Port value used if service specifies SRV record"
  type = number
  default = 0
}

variable "service_registries_container_port" {
  description = "Task def port value to be used for service discovery service"
  type = number
  default = 0
}

variable "service_registries_container_name" {
  description = "Task def container name to be used for service discovery service"
  type = number
  default = 0
}

variable "tags" {
  description = "Key-value map of resource tags"
  type = any
  default = null
}

variable "wait_for_steady_state" {
  description = "If true, Terraform waits until service reaches a steady state before continuing"
  type = bool
  default = false
}