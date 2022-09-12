variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "aws_route_table" {
  type = "?"
}

variable "cidr" {
  type = string
}

