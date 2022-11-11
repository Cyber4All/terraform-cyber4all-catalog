variable "mongodbatlas_private_key" {
  description = "Private key for mongodb"
  type        = string
}

variable "mongodbatlas_public_key" {
  description = "Public key for mongodb"
  type        = string
}

variable "nat_gateway_ip" {
  description = "the ip address for the NAT gateway to connect to the DB"
  type        = string
}

variable "project_id" {
  description = "the id of the DB to connect to"
  type        = string
}