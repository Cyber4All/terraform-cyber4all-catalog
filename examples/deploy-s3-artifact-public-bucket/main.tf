terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "s3_artifact" {
  source = "../../modules/s3-artifact"

  bucket_name          = var.bucket_name
  enable_public_access = var.enable_public_access
}
