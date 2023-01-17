# ---------------------------------------------------------------------------------------------------------------------
# AWS S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET ACL
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
# IAM POLICY WITH ACCESS TO S3 BUCKET
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
      "arn:aws:s3:::${var.bucket_name}/*",
      "arn:aws:s3:::${var.bucket_name}",
      aws_dynamodb_table.arn
    ]
  }

  statement {
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "tf_s3_backend_policy" {
  name        = "${var.bucket_name}_s3_backend"
  description = "Policy that permits backend permissions needed for terraform apply"

  policy = data.aws_iam_policy_document.tf_s3_backend_policy.json
}
