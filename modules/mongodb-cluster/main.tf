# -------------------------------------------------------------------------------------
# MongoDB Cluster
# 
# This module will create a mongodb cluster in an existing project.
#
# The module includes the following:
# - MongoDB Cluster
#
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

  required_providers {
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
