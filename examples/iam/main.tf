terraform {
  required_version = "1.2.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }

  backend "s3" {
    bucket = "competency-service-terraform-state"
    key    = "live/example/iam/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "competency-service-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowFullS3Access"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

module "iam_example_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.4.0"

  name        = "CustomS3BucketPolicy"
  description = "Example policy with s3"

  policy = data.aws_iam_policy_document.bucket_policy.json

  tags = {
    PolicyDescription = "Policy created using example from data source"
  }
}

module "iam_iam-assumable-role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.4.0"

  trusted_role_services = [
    "s3.amazonaws.com"
  ]

  create_role = true

  role_name        = "CustomExampleS3Role"
  role_description = "Custom role to test terraform IAM modules"

  custom_role_policy_arns = [
    module.iam_example_iam-policy.arn
  ]
}

