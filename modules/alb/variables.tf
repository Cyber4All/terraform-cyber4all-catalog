# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Name that will prepend all resources."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where to create security group."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "access_log_bucket" {
  description = "The S3 bucket name to store the logs in."
  type        = string
  default     = null
}

# ----------------------------------------------------
# external security group parameters
# ----------------------------------------------------
variable "external_sg_description" {
  type        = string
  description = "Description of security group."
  default     = "External ALB Security Group managed by Terraform"
}

variable "external_ingress_rules" {
  type        = list(string)
  description = "List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf)."
  default     = []
}

variable "external_egress_rules" {
  type        = list(string)
  description = "List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf)."
  default     = []
}

variable "external_ingress_with_cidr_blocks" {
  type        = list(map(string))
  description = "List of ingress rules to create where 'cidr_blocks' is used."
  default     = []
}

variable "external_egress_with_cidr_blocks" {
  type        = list(map(string))
  description = "List of egress rules to create where 'cidr_blocks' is used."
  default     = []
}

variable "external_ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used."
  type        = list(map(string))
  default     = []
}

variable "external_egress_with_source_security_group_id" {
  description = "List of egress rules to create where 'source_security_group_id' is used."
  type        = list(map(string))
  default     = []
}

# ----------------------------------------------------
# internal security group parameters
# ----------------------------------------------------

variable "internal_sg_description" {
  type        = string
  description = "Description of security group."
  default     = "External ALB Security Group managed by Terraform"
}

variable "internal_ingress_rules" {
  type        = list(string)
  description = "List of ingress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf)."
  default     = []
}

variable "internal_egress_rules" {
  type        = list(string)
  description = "List of egress rules to create by name (https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/v4.15.0/rules.tf)."
  default     = []
}

variable "internal_ingress_with_cidr_blocks" {
  type        = list(map(string))
  description = "List of ingress rules to create where 'cidr_blocks' is used."
  default     = []
}

variable "internal_egress_with_cidr_blocks" {
  type        = list(map(string))
  description = "List of egress rules to create where 'cidr_blocks' is used."
  default     = []
}

variable "internal_ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used."
  type        = list(map(string))
  default     = []
}

variable "internal_egress_with_source_security_group_id" {
  description = "List of egress rules to create where 'source_security_group_id' is used."
  type        = list(map(string))
  default     = []
}

# ----------------------------------------------------
# external application load balancer parameters
# ----------------------------------------------------
variable "create_external_alb" {
  type        = bool
  description = "Controls if the External Application Load Balancer should be created"
  default     = true
}

variable "public_subnet_ids" {
  description = "List of public subnet ARNs to deploy external ALB into (required if create_external_alb == true)"
  type        = list(string)
  default     = []
}

variable "external_http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])."
  type        = any
  default     = []
}

variable "external_http_tcp_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index])."
  type        = any
  default     = []
}

variable "external_https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])."
  type        = any
  default     = []
}

variable "external_https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])."
  type        = any
  default     = []
}

variable "external_target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port."
  type        = any
  default     = []
}

# ----------------------------------------------------
# internal application load balancer parameters
# ----------------------------------------------------
variable "create_internal_alb" {
  type        = bool
  description = "Controls if the Internal Application Load Balancer should be created"
  default     = true
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to deploy internal ALB into (required if create_internal_alb == true)"
  type        = list(string)
  default     = []
}

variable "internal_http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])."
  type        = any
  default     = []
}

variable "internal_http_tcp_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index]."
  type        = any
  default     = []
}

variable "internal_https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])."
  type        = any
  default     = []
}

variable "internal_https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])."
  type        = any
  default     = []
}

variable "internal_target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port."
  type        = any
  default     = []
}
