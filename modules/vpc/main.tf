# -------------------------------------------------------------------------------------
# VIRTUAL PRIVATE CLOUD (VPC)
# 
# This module will create a VPC that can be used for application deployments.
#
# The module creates a VPC with both public and private subnets. For production
# deployments, at least three availability zones (AZs) should be used. For non-
# production deployments one subnet should suffice. For cost savings using one 
# NAT gateway will work. For highly-available workloads, one NAT should be used
# per AZ.
#
# The module includes the following:
#
# - VPC
# - Internet Gateway
# - NAT Gateways
# - Public Subnets
# - Public Subnets' Route Table
# - Public Subnets' NACL
# - Private Subnets
# - Private Subnets' Route Table
# - Private Subnets' NACL
#
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE VPC,

# INTERNET GATEWAY (IGW), AND NAT GATEWAY

# ------------------------------------------------------------


# --------------------------------------------------------------------
# CREATE THE VPC
# --------------------------------------------------------------------

resource "aws_vpc" "this" {}


# --------------------------------------------------------------------
# CREATE THE INTERNET GATEWAY
# --------------------------------------------------------------------

resource "aws_internet_gateway" "this" {}


# --------------------------------------------------------------------
# CREATE THE NAT GATEWAY
# --------------------------------------------------------------------

# Condition: NAT should only be created if private subnets exist
# Condition: There should be an option to reuse the EIP between
# the different NATs if num_nat_gateways > 1

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "this" {}

resource "aws_route" "private_nat_gateway" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE

# PUBLIC AND PRIVATE SUBNETS, AS WELL AS THE

# ROUTE TABLES AND NACL FOR EACH SUBNET

# ------------------------------------------------------------


# --------------------------------------------------------------------
# CREATE THE PUBLIC SUBNETS
# --------------------------------------------------------------------

# Condition: The number of subnets created should be based
# on the num_availability_zones selected. If value not set then
# the max number of subnets in a given region is used
# Condition: The subnet cidr should be computed based on the
# VPC CIDR and the number subnet being created.
# Condition (optional): A variable that allows the toggle of public
# subnets var.create_public_subnets default true

resource "aws_subnet" "public" {}


# --------------------------------------------------------------------
# CREATE THE PUBLIC ROUTE TABLES
# --------------------------------------------------------------------

# Condition: Only a single route table should be created in the
# public subnets route table, which is to route traffic to the 
# IGW

resource "aws_route_table" "public" {}

resource "aws_route_table_association" "public" {}

resource "aws_route" "public_igw" {}


# --------------------------------------------------------------------
# CREATE THE PUBLIC NACL
# --------------------------------------------------------------------

# Condition: The public NACL should use the default option

resource "aws_network_acl" "public" {}

resource "aws_network_acl_rule" "public_ingress" {}

resource "aws_network_acl_rule" "public_egress" {}


# --------------------------------------------------------------------
# CREATE THE PRIVATE SUBNETS
# --------------------------------------------------------------------

# Condition: The number of subnets created should be based
# on the num_availability_zones selected. If value not set then
# the max number of subnets in a given region is used
# Condition: The subnet cidr should be computed based on the
# VPC CIDR and the number subnet being created.
# Condition (optional): A variable that allows the toggle of private
# subnets var.create_private_subnets default true

resource "aws_subnet" "private" {}


# --------------------------------------------------------------------
# CREATE THE PRIVATE ROUTE TABLES
# --------------------------------------------------------------------

# Condition: The route tables should direct traffic to the NAT
# deployed into the public subnet(s)

resource "aws_route_table" "private" {}

resource "aws_route_table_association" "private" {}

resource "aws_route" "private_nat" {}


# --------------------------------------------------------------------
# CREATE THE PRIVATE NACL
# --------------------------------------------------------------------

resource "aws_network_acl" "private" {}

resource "aws_network_acl_rule" "private_ingress" {}

resource "aws_network_acl_rule" "private_egress" {}
