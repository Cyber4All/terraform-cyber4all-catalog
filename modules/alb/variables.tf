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

variable "alb_name" {
  type        = string
  description = "The name of the ALB."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the ALB will be created."
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "The ids of the subnets that the ALB can use to source its IP."
}


# --------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These values are optional and have default values provided
# --------------------------------------------------------------------

variable "dns_record_prefix" {
  type        = string
  description = "The prefix of the DNS A record that will be created for the ALB."
  default     = "api"
}

variable "enable_https_listener" {
  type        = bool
  description = "Creates an HTTPS listener for the ALB. When enabled the ALB will redirect HTTP traffic to HTTPS automatically."
  default     = true
}

variable "hosted_zone_name" {
  type        = string
  description = "The name of the hosted zone where the ALB DNS record will be created."
  default     = ""
}
