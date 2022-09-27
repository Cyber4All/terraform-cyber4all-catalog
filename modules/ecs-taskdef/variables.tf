# --------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------

variable "family" {
  description = "The unique name for the task definition"
  type = string
}

# variable "container_definitions" {
#   description = "A list of containers with container definitions provided as a single JSON document"
#   type = list(object({
#     name = string
#     image = string
#     memory = number # hard limit of memory (in MiB) for a container, killed if limit exceeded, required for EC2 container types (specified in requires_compatibilities)
#   }))
# }

# --------------------------------------------------------
# OPTIONAL PARAMETERS
# All the parameters below are optional.
# These parameters have reasonable defaults.
# --------------------------------------------------------

variable "requires_compatibilities" {
  description = "Specifies ECS container types"
  type = list(string) # accepted strings "EC2" | "FARGATE" | "EXTERNAL"
  default = [ "EC2" ]
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows containers to make calls to other AWS sevices"
  type = string
  default = null
}

variable "execution_role_arn" {
  description = "ARN of task execution role that container or daemon can assume"
  type = string
  default = null
}

variable "network_mode" {
  description = "Docker networking mode to use for containers in the task"
  type = string # "none" | "bridge" | "awsvpc" | "host"
  default = "awsvpc"
}

variable "cpu" {
  description = "Hard limit of CPU units for the task"
  type = string # can be expressed as integer ('1024' for 1024 units) or a string for vCPUs ('1 vcpu' for 1 vcpu)
  default = null
}

variable "memory" {
  description = "Amount (in MiB) of memory used for the task. Killed if exceeded. Required if requires_compatibilities is FARGATE"
  type = string # can be expressed as integer ('1024' for 1024 MiBs) or a string using GB ('1GB' for 1 GB of memory)
  default = null
}

variable "tags" {
  description = "Metadata tags applied to the task def, defined in key-value pairs"
  type = any # key-value form "tag-type": "tag-value"
  default = null
}

variable "ipc_mode" {
  description = "IPC resource namespace to be used for the containers in the task"
  type = string # "host" | "task" | "none"
  default = "none"
}

variable "pid_mode" {
  description = "Process namespace to use for containers in the task"
  type = string # "host" | "task"
  default = null
}

variable "skip_destroy" {
  description = "Whether or not to retain the revision when the original resource is destroyed"
  type = bool
  default = false
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR runtime_platform
# The following parameters are required for FARGATE launch types.
# --------------------------------------------------------

variable "operating_system_family" {
  description = "Specifies OS family to use"
  type = string
  default = null
}

variable "cpu_architecture" {
  description = "Specify CPU architecture"
  type = string # "X86_64" | "ARM64"
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR placement_constraints
# Customizes how ECS places tasks. Not supported for FARGATE container types.
# --------------------------------------------------------

variable "placement_constraints_type" {
  description = "Type of constraint. Required if placement_constraints exists."
  type = string
  default = null
}

variable "placement_constraints_expression" {
  description = "A cluster query language expression to apply to the constraint."
  type = string
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR proxy_configuration
# Configuration details for the App Mesh proxy.
# --------------------------------------------------------

variable "proxy_configuration_type" {
  description = "The Proxy type"
  type = string # only supported value is "APPMESH"
  default = "APPMESH"
}

variable "proxy_configuration_container_name" {
  description = "The name of the container that serves as the App Mesh Proxy"
  type = string
  default = null
}

variable "proxy_configuration_properties" {
  description = "The set of network configuration parameters to provide the Container Network Interface"
  type = object({
    IgnoredUID = string # userID of the proxy container
    IgnoredGID = string # groupID of the proxy container
    AppPorts = list(string) # List of ports that the application uses
    ProxyIngressPort = number # Specifies port for incoming traffic to AppPorts
    ProxyEgressPort = number # Specifies port for outgoing traffic from AppPorts
    EgressIgnoredPorts = list(string) # List of ports where any outbound traffic going to these ports is ignored and not redirected to ProxyEgressPort. Can be an empty list.
    EgressIgnoredIPs = list(string) # List of IPs where any outbound traffic going to these ports is ignored and not redirected to ProxyEgressPort. Can be an empty list.
  })
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR ephemeral_storage
# Configuration details for the amount of ephemeral storage for FARGATE tasks.
# --------------------------------------------------------

variable "ephemeral_storage_size_in_gib" {
  description = "Total amount (in GiB) of ephemeral storage to set for the task"
  type = number # 21 <= value <= 200
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR volumes
# Configuration details for persisting data storage throughout containers.
# --------------------------------------------------------

variable "volume_name" {
  description = "name of the volume"
  type = string
  default = null
}

variable "volume_host_path" {
  description = "Path on the host container instance that is presented to the container"
  type = string
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR volumes.docker_volume_configuration
# An object used as a parameter within the volumes variable.
# --------------------------------------------------------

variable "docker_volume_configuration_scope" {
  description = "Determines the lifecycle of the volume. If 'task', then lasts until end of task. If 'shared', persists even after task stops."
  type = string # "task" | "shared"
  default = "null"
}

variable "docker_volume_configuration_autoprovision" {
  description = "Determines whether volumes are automatically created if they don't exist. Use only when scope is set to 'shared'."
  type = bool
  default = false
}

variable "docker_volume_configuration_driver" {
  description = "Docker volume driver to use. Must match the driver name provided by Docker for task placement"
  type = string
  default = null
}
variable "docker_volume_configuration_driver_opts" {
  description = "Map of Docker driver specific options"
  type = string
  default = null
}

variable "docker_volume_configuration_labels" {
  description = "Custom metadata to add to the volume"
  type = string
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR volumes.efs_volume_configuration AND volumes.fsx_windows_file_server_volume_configuration
# An object used as a parameter within the volumes variable.
# --------------------------------------------------------

variable "file_system_id" {
  description = "ID of the EFS File System OR the Amason FSx for Windows File Serve file system ID to use"
  type = string
  default = null
}

variable "root_directory" {
  description = "Directory within file system to mount as the root directory"
  type = string
  default = null
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR volumes.efs_volume_configuration ONLY
# An object used as a parameter within the volumes variable.
# --------------------------------------------------------
variable "efs_volume_configuration_transit_encryption" {
  description = "Whether or not to enable encryption in transit between ECS host and EFS server"
  type = string # "ENABLED" | "DISABLED"
  default = null
}

variable "efs_volume_configuration_transit_encryption_port" {
  description = "Port to use when sending data between ECS host and EFS server"
  type = number
  default = null
}

variable "efs_volume_configuration_access_point_id" {
  description = "Access Point ID to use"
  type = string
  default = null
}

variable "efs_volume_configuration_iam" {
  description = "Whether or not to use the Amazon ECS task IAM role defined in a task def"
  type = string # "ENABLED" | "DISABLED"
  default = "DISABLED"
}

# --------------------------------------------------------
# CONFIGURATION PARAMETERS FOR volumes.fsx_windows_file_server_volume_configuration ONLY
# An object used as a parameter within the volumes variable.
# --------------------------------------------------------

variable "credentials_parameter" {
  description = "The authorization credential options"
  type = string # Can be ARN of AWS Secrets Manager secret or ARN of AWS Systems Manager parameter
  default = null
}

variable "domain" {
  description = "Fully qualified domain name hosted by an AWS Directory Service"
  type = string
  default = null
}