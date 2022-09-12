variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "aws_route_table" {
  type = list(string)
}

variable "cidr" {
  type = string
}

