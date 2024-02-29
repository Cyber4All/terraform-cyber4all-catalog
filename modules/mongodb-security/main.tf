# -------------------------------------------------------------------------------------
# MongoDB Security Module
# 
# This module configures a MongoDB Project's security module.
#
# The MongoDB project can be configured to use VPC peering to connect to the VPC of 
# the application. This allows the application to connect to the MongoDB project
# without exposing the project to the public internet.
#
# Additionally, the module can be configured to use AWS IAM to manage access to the
# MongoDB cluster. This allows the application to use the same AWS IAM users and roles
# to access the MongoDB cluster.
#
# The module includes the following:
# - MongoDB Database Users
# - VPC Peering Connection
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
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.12.1"
    }
  }
}

# Gets the information about the MongoDB Project
data "mongodbatlas_project" "project" {
  name = var.project_name
}


# --------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE DATABASE

# ACCESS FOR THE CLUSTER USING AWS IAM

# --------------------------------------------------------------

# Gets the AWS IAM User information using the username
# specified in the variable map
data "aws_iam_user" "user" {
  for_each = var.authorized_iam_users

  user_name = each.key
}


# -------------------------------------------
# CREATE DB USERS USING IAM USER
# -------------------------------------------

locals {
  # Maps the AWS IAM User to the database access role
  # specified in the configuration
  aws_iam_user_arn_role_map = {
    for user in data.aws_iam_user.user :
    user.arn => split("@", var.authorized_iam_users[user.user_name])
  }
}

resource "mongodbatlas_database_user" "user" {
  for_each = local.aws_iam_user_arn_role_map

  project_id         = data.mongodbatlas_project.project.id
  auth_database_name = "$external"

  aws_iam_type = "USER"
  username     = each.key

  dynamic "roles" {
    for_each = each.value[0] == "admin" ? [1] : []
    content {
      role_name     = "atlasAdmin"
      database_name = "admin"
    }
  }

  dynamic "roles" {
    for_each = each.value[0] == "readWrite" ? [1] : []
    content {
      role_name     = "readWriteAnyDatabase"
      database_name = "admin"
    }
  }

  dynamic "roles" {
    for_each = each.value[0] == "read" ? [1] : []
    content {
      role_name     = "readAnyDatabase"
      database_name = "admin"
    }
  }

  dynamic "scopes" {
    for_each = each.value.length == 2 ? [1] : []
    content {
      name = each.value[1]
      type = "CLUSTER"
    }
  }
}


# -------------------------------------------
# CREATE DB USERS USING IAM ROLE
# -------------------------------------------

data "aws_iam_role" "role" {
  for_each = var.authorized_iam_roles

  name = each.key
}

locals {
  aws_iam_role_arn_role_map = {
    for role in data.aws_iam_role.role :
    role.arn => split("@", var.authorized_iam_roles[role.id])
  }
}


resource "mongodbatlas_database_user" "role" {
  for_each = local.aws_iam_role_arn_role_map

  project_id         = data.mongodbatlas_project.project.id
  auth_database_name = "$external"

  aws_iam_type = "ROLE"
  username     = each.key

  dynamic "roles" {
    for_each = each.value == "admin" ? [1] : []
    content {
      role_name     = "atlasAdmin"
      database_name = "admin"
    }
  }

  dynamic "roles" {
    for_each = each.value == "readWrite" ? [1] : []
    content {
      role_name     = "readWriteAnyDatabase"
      database_name = "admin"
    }
  }

  dynamic "roles" {
    for_each = each.value == "read" ? [1] : []
    content {
      role_name     = "readAnyDatabase"
      database_name = "admin"
    }
  }

  dynamic "scopes" {
    for_each = each.value.length == 2 ? [1] : []
    content {
      name = each.value[1]
      type = "CLUSTER"
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# THE VPC PEERING FOR AWS

# ------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_route_table" "peering" {
  # Assuming that each route table belongs to a unique VPC
  count = var.enable_vpc_peering && length(var.peering_route_table_ids) > 0 ? length(var.peering_route_table_ids) : 0

  route_table_id = var.peering_route_table_ids[count.index]
}

locals {
  # Get a list of unique vpc ids
  # Assuming that each route table belongs to a unique VPC
  vpc_ids = [
    for rt in data.aws_route_table.peering :
    rt.vpc_id
  ]
}

data "mongodbatlas_clusters" "peering" {
  count = var.enable_vpc_peering ? 1 : 0

  project_id = data.mongodbatlas_project.project.id

  lifecycle {
    postcondition {
      condition     = length(self.results) > 0
      error_message = "Atleast one cluster must exist before creating a network peering connection."
    }
  }
}


data "mongodbatlas_advanced_cluster" "peering" {
  count = var.enable_vpc_peering ? 1 : 0

  project_id = data.mongodbatlas_project.project.id
  name       = data.mongodbatlas_clusters.peering[0].results[0].name
}

resource "mongodbatlas_network_peering" "peering" {
  count = var.enable_vpc_peering ? length(data.aws_route_table.peering) : 0

  project_id    = data.mongodbatlas_project.project.id
  container_id  = data.mongodbatlas_advanced_cluster.peering.container_id
  provider_name = "AWS"

  accepter_region_name   = data.aws_region.current.name
  aws_account_id         = data.aws_caller_identity.current.account_id
  vpc_id                 = local.vpc_ids[count.index]
  route_table_cidr_block = var.peering_cidr_block

  depends_on = [
    data.aws_route_table.peering
  ]

  lifecycle {
    precondition {
      condition     = length(data.aws_route_table.peering) == length(local.vpc_ids)
      error_message = "The number of route tables must match the number of VPCs."
    }
  }
}

resource "aws_vpc_peering_connection_accepter" "peering" {
  count = var.enable_vpc_peering ? length(mongodbatlas_network_peering.peering) : 0

  vpc_peering_connection_id = mongodbatlas_network_peering.peering[count.index].connection_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
    Name = "${data.mongodbatlas_project.project.name}-peering-accepter${count.index}"
  }

  depends_on = [
    mongodbatlas_network_peering.peering
  ]
}

data "aws_vpc_peering_connection" "peering" {
  count = var.enable_vpc_peering ? length(mongodbatlas_network_peering.peering) : 0

  id = mongodbatlas_network_peering.peering[count.index].connection_id

  depends_on = [
    aws_vpc_peering_connection_accepter.peering
  ]
}


# -------------------------------------------
# CREATE THE ROUTE FOR THE PEERING CONNECTION
# -------------------------------------------

locals {
  route_table_id_to_vpc_id = {
    for rt in data.aws_route_table.peering :
    # The "..." represents ellipsis and is used to
    # spread the values of the map into a list of values
    # All values in the list are the same which is why
    # it is safe to use the first value
    rt.route_table_id => rt.vpc_id...
  }

  # THESE TWO MAPS CAN BE USE THE VPC ID
  # TO GET THE PEERING CONNECTION INFORMATION

  vpc_id_to_peering_connection_cidr_block = {
    for pcx in data.aws_vpc_peering_connection.peering :
    pcx.peer_vpc_id => pcx.cidr_block
  }

  vpc_id_to_peering_connection_id = {
    for pcx in data.aws_vpc_peering_connection.peering :
    pcx.peer_vpc_id => pcx.id
  }


  # THE FOLLOWING CREATES A LIST OF OBJECTS THAT ASSOCIATE
  # THE ROUTE TABLE ID WITH THE PEERING CONNECTION ID
  # AND THE PEER DESTINATION CIDR BLOCK

  route_table_ids = distinct([
    for rt in data.aws_route_table.peering :
    rt.route_table_id
  ])

  route_list = [
    for route_table_id in local.route_table_ids :
    {
      route_table_id = route_table_id

      destination_cidr_block    = local.vpc_id_to_peering_connection_cidr_block[local.route_table_id_to_vpc_id[route_table_id][0]]
      vpc_peering_connection_id = local.vpc_id_to_peering_connection_id[local.route_table_id_to_vpc_id[route_table_id][0]]
    }
  ]
}

resource "aws_route" "peering" {
  # Assuming that a route will be added to each route table
  count = var.enable_vpc_peering && length(var.peering_route_table_ids) > 0 ? length(var.peering_route_table_ids) : 0

  route_table_id = local.route_list[count.index].route_table_id

  destination_cidr_block    = local.route_list[count.index].destination_cidr_block
  vpc_peering_connection_id = local.route_list[count.index].vpc_peering_connection_id

  depends_on = [
    aws_vpc_peering_connection_accepter.peering,
    data.aws_route_table.peering,
  ]
}
