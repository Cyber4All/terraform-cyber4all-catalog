variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "list of ingress cidr blocks for the security group to be created"
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "list of ingress cidr blocks for the security group to be created"
}

variable "ingress_rules" {
  type        = list(string)
  description = "list of ingress rules for the security group to be created"
}

variable "egress_rules" {
  type        = list(string)
  description = "list of egress rules for the security group to be created"
}

variable "vpc_id" {
  type = string
  description = "the id of the vpc to associate with this security group"
}

variable "security_group_description" {
    type = string
    description = "the description of the security group to create"
}