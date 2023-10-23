terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.priamry_region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

module "s3_artifact" {
  source = "../../modules/s3-artifact"

  primary_bucket_name = var.primary_bucket_name
  replica_bucket_name = var.replica_bucket_name
}
