terraform {
  required_version = "1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS S3 BUCKET IN PROVIDED REGION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
}

# ---------------------------------------------------------------------------------------------------------------------
# CONGFIGURE BUCKET WITH PRIVATE ACL (Prevents Public Access)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_acl" "backend" {
  bucket = aws_s3_bucket.backend.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------------------------------------------------
# ENABLE OBJECT VERSIONING TO PROTECT .tfstate FILES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE SERVER SIDE ENCRYPTION FOR ALL BUCKET CONTENT (Confidentiallity for .tfstate files)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PROVISION DB TABLE FOR LOCKING OF .tfstate FILES (Provides integrity to frequent changing infrastructure)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Provisions IAM Role with a custom policy that can access the S3 backend bucket
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "tf_s3_backend_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::competency-service-terraform-state/*",
      "arn:aws:s3:::competency-service-terraform-state",
      "arn:aws:dynamodb:us-east-1:317620868823:table/competency-service-terraform-locks"
    ]
  }

  statement {
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "tf_s3_backend_policy" {
  name        = "${var.environment}_s3_backend_policy"
  path        = var.path
  description = "Policy that permits backend permissions needed for terraform apply"

  policy = data.aws_iam_policy_document.tf_s3_backend_policy.json
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.4.0"

  trusted_role_services = [
    "s3.amazonaws.com"
  ]

  create_role = true

  role_name        = "S3RemoteBackendRole"
  role_description = "Role permits updating tfstate files for terraform IaC"

  custom_role_policy_arns = [
    aws_iam_policy.tf_s3_backend_policy.arn
  ]
}
