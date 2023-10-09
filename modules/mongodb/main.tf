# -------------------------------------------------------------------------------------
# MongoDB Cluster
# 
# This module will create a mongodb cluster that integrates with an existing AWS VPC.
#
# The MongoDB cluster can...
#
# The module includes the following:
#
# - TODO: ADD THIS IN DEVELOPMENT
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


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# THE MONGO DB CLUSTER

# ------------------------------------------------------------


data "mongodbatlas_project" "project" {
  name = var.project_name
}


# -------------------------------------------
# CONVENIENCE VARIABLES FOR THE CLUSTER
# -------------------------------------------

locals {
  regions_map = {
    "us-east-1" : "US_EAST_1",
    "us-east-2" : "US_EAST_2",
    "us-west-1" : "US_WEST_1",
    "us-west-2" : "US_WEST_2",
  }

  instance_map = {
    "M10" : {
      "min_storage_size" : 10,
      "max_storage_size" : 128,
      "ram_size" : 2
    },
    "M20" : {
      "min_storage_size" : 10,
      "max_storage_size" : 255,
      "ram_size" : 4
    },
    "M30" : {
      "min_storage_size" : 10,
      "max_storage_size" : 512,
      "ram_size" : 8
    },
    "M40" : {
      "min_storage_size" : 10,
      "max_storage_size" : 1024,
      "ram_size" : 16
    },
    "M50" : {
      "min_storage_size" : 10,
      "max_storage_size" : 4096,
      "ram_size" : 32
    }
  }
}


# -------------------------------------------
# CREATE THE CLUSTER
# -------------------------------------------

resource "mongodbatlas_cluster" "cluster" {
  project_id    = data.mongodbatlas_project.project.id
  provider_name = "AWS"

  # WARNING: Updating this will force a new resource to be created
  name = var.cluster_name

  mongo_db_major_version = var.cluster_mongodb_version
  version_release_system = var.enable_cluster_automated_patches ? "LTS" : null


  # Storage Size Auto Scaling
  auto_scaling_disk_gb_enabled = var.enable_cluster_auto_scaling
  disk_size_gb                 = var.cluster_disk_size_gb


  # Cluster Tier Compute Auto Scaling
  auto_scaling_compute_enabled                    = var.enable_cluster_auto_scaling
  auto_scaling_compute_scale_down_enabled         = var.enable_cluster_auto_scaling
  provider_instance_size_name                     = var.cluster_instance_name
  provider_auto_scaling_compute_max_instance_size = "M50"
  provider_auto_scaling_compute_min_instance_size = "M10"


  # Backup Configuration
  cloud_backup           = var.enable_cluster_backups
  pit_enabled            = var.enable_cluster_backups
  retain_backups_enabled = var.enable_retain_deleted_cluster_backups

  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1

    regions_config {
      region_name = local.regions_map[var.cluster_region]

      # Represents the number of nodes in a given region
      # that can be configured as writable or read-only nodes.
      electable_nodes = 3

      # Priority 7 is the highest priority and represents
      # the primary node. Priority 1 is the lowest priority.
      priority = 7
    }
  }

  termination_protection_enabled = var.enable_cluster_terimination_protection

  lifecycle {
    precondition {
      condition = (
        var.cluster_disk_size_gb >= local.instance_map[var.cluster_instance_name].min_storage_size &&
        var.cluster_disk_size_gb <= local.instance_map[var.cluster_instance_name].max_storage_size
      )
      error_message = "Disk size must be between ${local.instance_map[var.cluster_instance_name].min_storage_size} and ${local.instance_map[var.cluster_instance_name].max_storage_size}"
    }

    ignore_changes = [
      # Prevents overwriting auto scaling changes
      # that are made outside of terraform
      disk_size_gb,
      provider_instance_size_name
    ]
  }

  depends_on = [
    data.mongodbatlas_project.project
  ]
}


# -------------------------------------------
# CREATE THE NOTIFCATION
# -------------------------------------------

# should send notification to slack and/or email
# notify if storage is x % full
# any other metrics deemed useful here https://www.mongodb.com/basics/how-to-monitor-mongodb-and-what-metrics-to-monitor
# resource "mongodbatlas_alert_configuration" "cluster" {}

# --------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE DATABASE

# ACCESS FOR THE CLUSTER USING AWS IAM

# --------------------------------------------------------------

locals {
  # Maps the AWS IAM User to the database access role
  # specified in the configuration
  aws_iam_user_arn_role_map = {
    for user in data.aws_iam_user.user :
    user.arn => var.cluster_authorized_iam_users[user.user_name]
  }

  aws_iam_role_arn_role_map = {
    for role in data.aws_iam_role.role :
    role.arn => var.cluster_authorized_iam_roles[role.id]
  }

}

# -------------------------------------------
# CREATE DB USERS USING IAM USER
# -------------------------------------------

data "aws_iam_user" "user" {
  for_each = var.cluster_authorized_iam_users

  user_name = each.key
}


resource "mongodbatlas_database_user" "user" {
  for_each = local.aws_iam_user_arn_role_map

  project_id         = data.mongodbatlas_project.project.id
  auth_database_name = "$external"

  aws_iam_type = "USER"
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

  scopes {
    name = var.cluster_name
    type = "CLUSTER"
  }
}


# -------------------------------------------
# CREATE DB USERS USING IAM ROLE
# -------------------------------------------

data "aws_iam_role" "role" {
  for_each = var.cluster_authorized_iam_roles

  name = each.key
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

  scopes {
    name = var.cluster_name
    type = "CLUSTER"
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CONFIGURE

# THE VPC PEERING FOR AWS

# ------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_route_table" "peering" {
  count = var.enable_vpc_peering && length(var.cluster_peering_route_table_ids) > 0 ? length(var.cluster_peering_route_table_ids) : 0

  route_table_id = var.cluster_peering_route_table_ids[count.index]
}

locals {
  # Get a list of unique vpc ids
  vpc_ids = distinct([
    for rt in data.aws_route_table.peering :
    rt.vpc_id
  ])
}

resource "mongodbatlas_network_peering" "peering" {
  count = var.enable_vpc_peering && length(local.vpc_ids) > 0 ? length(local.vpc_ids) : 0

  project_id    = data.mongodbatlas_project.project.id
  container_id  = mongodbatlas_cluster.cluster.container_id
  provider_name = "AWS"

  accepter_region_name   = data.aws_region.current.name
  aws_account_id         = data.aws_caller_identity.current.account_id
  vpc_id                 = local.vpc_ids[count.index]
  route_table_cidr_block = var.cluster_peering_cidr_block

  depends_on = [
    data.aws_route_table.peering
  ]
}

resource "aws_vpc_peering_connection_accepter" "peering" {
  count = var.enable_vpc_peering && length(mongodbatlas_network_peering.peering) > 0 ? length(mongodbatlas_network_peering.peering) : 0

  vpc_peering_connection_id = mongodbatlas_network_peering.peering[count.index].connection_id
  auto_accept               = true

  tags = {
    Side = "Accepter"
    Name = "${var.cluster_name}-peering-accepter${count.index}"
  }

  depends_on = [
    mongodbatlas_network_peering.peering
  ]
}

data "aws_vpc_peering_connection" "peering" {
  count = var.enable_vpc_peering && length(mongodbatlas_network_peering.peering) > 0 ? length(mongodbatlas_network_peering.peering) : 0

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
  count = var.enable_vpc_peering && length(local.route_list) > 0 ? length(local.route_list) : 0

  route_table_id = local.route_list[count.index].route_table_id

  destination_cidr_block    = local.route_list[count.index].destination_cidr_block
  vpc_peering_connection_id = local.route_list[count.index].vpc_peering_connection_id
}
