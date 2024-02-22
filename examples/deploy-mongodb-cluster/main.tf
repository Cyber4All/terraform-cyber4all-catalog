terraform {
  required_providers {

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.12.1"
    }
  }
}

provider "mongodbatlas" {
  assume_role {
    role_arn = var.mongodb_role_arn
  }
  secret_name = "mongodb/project/sandbox"
  region      = "us-east-1"
}

module "mongodb" {
  source = "../../modules/mongodb-cluster"

  project_name = "Sandbox"
  cluster_name = "mongo-cluster-test${var.random_id}"

  # Disabled for testing purposes
  enable_cluster_terimination_protection = false

}
