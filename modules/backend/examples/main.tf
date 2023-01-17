terraform {
  required_version = "1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  project_name = "example_backend"
}

module "backend" {
  source  = "github.com/Cyber4All/terraform-module//modules/s3-backend?ref=v1.0.0"

  bucket_name = locals.project_name
  dynamodb_table_name = locals.project_name
}