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
    for_each = length(each.value) == 2 ? [1] : []
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
    for_each = length(each.value) == 2 ? [1] : []
    content {
      name = each.value[1]
      type = "CLUSTER"
    }
  }
}
