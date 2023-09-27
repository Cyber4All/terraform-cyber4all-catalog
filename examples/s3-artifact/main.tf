terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "s3-artifact" {
  source = "../../modules/s3-artifact"

  bucket_name = "my-bucket"
}
