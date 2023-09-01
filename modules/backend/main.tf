# ---------------------------------------------------------------------------------------------------------------------
# AWS S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name

  # tfsec:ignore:aws-s3-enable-bucket-logging
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

# tfsec:ignore:aws-s3-encryption-customer-key
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

# tfsec:ignore:aws-dynamodb-enable-recovery
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  server_side_encryption {
    enabled = true // enabled server side encryption
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
