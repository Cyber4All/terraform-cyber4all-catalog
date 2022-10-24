# --------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------

# ECS TASK DEFINITION
variable "task_family" {
  description = "The unique name for the task definition"
  type        = string
}

variable "container_definitions" {
  description = "A list of containers with container definitions provided as a single JSON document"
  type        = any
}

# ECS SERVICE

variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "cluster_arn" {
  description = "The ARN of the cluster where the service will be located"
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the given task definition to place and run"
  type        = number
}

variable "service_subnets" {
  description = "The list of subnets from the vpc to run the service in"
  type        = list(string)
}

variable "service_security_group_id" {
  description = "The id of the security group created"
  type        = string
}

# --------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------

# ECS TASK DEF

variable "network_mode" {
  description = "Docker networking mode to use for containers in the task"
  type        = string # "none" | "bridge" | "awsvpc" | "host"
  default     = "none"
}

variable "operating_system_family" {
  description = "Specifies OS family to use (required if launch type is FARGATE)"
  type        = string
  default     = null
}

variable "cpu_architecture" {
  description = "Specify CPU architecture (required if launch type is FARGATE)"
  type        = string # "X86_64" | "ARM64"
  default     = null
}

variable "task_cpu" {
  description = "Hard limit of CPU units for the task"
  type        = string # can be expressed as integer ('1024' for 1024 units) or a string for vCPUs ('1 vcpu' for 1 vcpu)
  default     = null
}

variable "requires_compatibilities" {
  description = "List of launch types to validate the task definition against"
  type        = list(string)
  default     = ["EC2"]
}

variable "ephemeral_storage" {
  description = "ephemeral storage block, consists (size_in_gib), Total amount (in GiB) of ephemeral storage to set for the task"
  type        = map(any) # 21 <= value <= 200
  default     = {}
}

variable "task_memory" {
  description = "Amount (in MiB) of memory used for the task. Killed if exceeded. Required if requires_compatibilities is FARGATE"
  type        = string # can be expressed as integer ('1024' for 1024 MiBs) or a string using GB ('1GB' for 1 GB of memory)
  default     = null
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows containers to make calls to other AWS sevices"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of task execution role that container or daemon can assume"
  type        = string
  default     = null
}

# ECS SERVICE

variable "launch_type" {
  description = "Service launch type"
  type        = string # "EC2" | "FARGATE" | "EXTERNAL"
  default     = "EC2"
}

variable "health_check_grace_period_seconds" {
  description = "The period of time, in seconds, that the Amazon ECS service scheduler should ignore unhealthy Elastic Load Balancing target health checks, container health checks, and Route 53 health checks after a task enters a RUNNING state."
  type        = number
  default     = 0
}

variable "load_balancer" {
  description = "Configuration block for load balancers. Consists of (target_group_arn, container_name, and container_port)"
  type        = map(any)
  default     = {}
}

variable "target_group_arn" {
  description = "ARN of the load balancer"
  type        = string
  default     = null
}

variable "container_name" {
  description = "The name of the container to associate with load balancer"
  type        = string
  default     = null
}

variable "container_port" {
  description = "The port of the container to associate with load balancer"
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
  type        = bool
  default     = false
}