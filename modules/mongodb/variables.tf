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
  description = "Name of the cluster as it appears in Atlas. Once the cluster is created, its name cannot be changed. WARNING: Changing the name will result in destruction of the existing cluster and the creation of a new cluster."
  type        = string
}

variable "project_name" {
  description = "Name of the project as it appears in Atlas to deploy the cluster into."
  type        = string
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "cluster_disk_size_gb" {
  description = "Capacity, in gigabytes, of the host's root volume. Increase this number to add capacity, up to a maximum possible value of 4096 (i.e., 4 TB). This value must be a positive integer."
  type        = number
  default     = 10
  validation {
    condition     = var.cluster_disk_size_gb >= 10 && var.cluster_disk_size_gb <= 4096
    error_message = "Disk size must be greater than 10 and less than or equal to 4096"
  }
}

variable "cluster_instance_name" {
  description = "The Atlas instance size name. Each Atlas instance size has a unique combination of memory, and storage capacity. See https://www.mongodb.com/docs/atlas/reference/amazon-aws/#cluster-configuration-options for more info."
  type        = string
  default     = "M10"
  validation {
    condition     = contains(["M10", "M20", "M30", "M40", "M50"], var.cluster_instance_name)
    error_message = "Instance support is only for M10, M20, M30, M40, M50. Contact module maintainer for more info."
  }
}

variable "cluster_mongodb_version" {
  description = "Version of the cluster to deploy. This module supports 4.4, 5.0, or 6.0. By default 5.0 is deployed."
  type        = string
  default     = "5.0"
  validation {
    condition     = contains(["4.4", "5.0", "6.0"], var.cluster_mongodb_version)
    error_message = "MongoDB version support is only for 4.4, 5.0, 6.0. Contact module maintainer for more info."
  }
}

variable "cluster_region" {
  description = "The AWS region to deploy the cluster into."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.cluster_region)
    error_message = "Region support is only for US. Must be one of the following, us-east-1, us-east-2, us-west-1, us-west-2. Contact module maintainer for more info."
  }
}

variable "cluster_authorized_iam_users" {
  description = "Create a map of AWS IAM users to assign an admin, readWrite, or read database role to the cluster's databases."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.cluster_authorized_iam_users : contains(["admin", "read", "readWrite"], v)])
    error_message = "A database role must be one of the following: admin, readWrite, read."
  }
}

variable "cluster_authorized_iam_roles" {
  description = "Create a map of AWS IAM roles to assign an admin, readWrite, or read database role to the cluster's databases."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.cluster_authorized_iam_roles : contains(["admin", "read", "readWrite"], v)])
    error_message = "A database role must be one of the following: admin, readWrite, read."
  }
}

variable "cluster_peering_subnets" {
  description = "TODO update this description"
  type        = list(string)
  default     = []
}

variable "enable_cluster_auto_scaling" {
  description = "Set to true to enable auto scaling for the cluster's compute and storage. Recommended for production clusters."
  type        = bool
  default     = false
}

variable "enable_cluster_automated_patches" {
  description = "Set to true to allow Atlas to automatically update your cluster to the latest patch release of the MongoDB version specified in the cluster_mongodb_version field."
  type        = bool
  default     = true
}

variable "enable_cluster_backups" {
  description = "Set to true to enable backups for the cluster. Recommended for production clusters."
  type        = bool
  default     = false
}

variable "enable_cluster_terimination_protection" {
  description = "Set to true to prevent terraform from deleting the Atlas cluster. Recommended for production clusters."
  type        = bool
  default     = false
}

variable "enable_retain_deleted_cluster_backups" {
  description = "Set to true to retain backup snapshots for the deleted cluster. Recommended for production clusters."
  type        = bool
  default     = false
}

variable "enable_vpc_peering" {
  description = "Set to true to enable a peering connection with an existing VPC."
  type        = bool
  default     = true
}
