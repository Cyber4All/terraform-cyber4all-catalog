# -------------------------------------------------------------------------------------
# MANAGE STATIC S3 ARTIFACTS
# -------------------------------------------------------------------------------------

# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# -------------------------------------------
# SET PROVIDER ALIAS FOR REPLICATION
# -------------------------------------------

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "replica"
  region = "us-east-2"
}


# -------------------------------------------
# CREATE A CUSTOMER MANAGED KEY TO ENCRYPT W/
# -------------------------------------------

resource "aws_kms_key" "s3_artifact" {
  description         = "CMK for S3 Artifacts Encryption"
  enable_key_rotation = true

}

# -------------------------------------------
# CREATE PRIMARY S3 BUCKET
# -------------------------------------------
resource "aws_s3_bucket" "s3_artifact" {
  bucket = "primary-s3-artifact-bucket-12345"
}

resource "aws_s3_bucket_acl" "s3_artifact" {
  bucket = aws_s3_bucket.s3_artifact.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3_artifact" {
  bucket = aws_s3_bucket.s3_artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_artifact_partial_lifecycle_management" {
  count = !var.full_lifecycle_management ? 1 : 0

  bucket = aws_s3_bucket.s3_artifact.id

  rule {
    id = "versioning-rule-12345"

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = 30
      newer_noncurrent_versions = 1
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_artifact_full_lifecycle_management" {
  count = var.full_lifecycle_management ? 1 : 0

  bucket = aws_s3_bucket.s3_artifact.id

  rule {
    id = "transition-rule-12345"

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

  }

  rule {
    id = "versioning-rule-12345"

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = 60
      newer_noncurrent_versions = 1
    }
  }
}

# -------------------------------------------
# CREATE S3 REPLICATION CONFIGURATION
# -------------------------------------------

data "aws_iam_policy_document" "s3_artifact_replica" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_artifact_replica" {
  name               = "tf-iam-role-replication-12345"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "s3_artifact_replica" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.source.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.source.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.destination.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_artifact_replica" {
  name   = "tf-iam-role-policy-replication-12345"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "s3_artifact_replica" {
  role       = aws_iam_role.s3_artifact_replica.name
  policy_arn = aws_iam_policy.s3_artifact_replica.arn
}

resource "aws_s3_bucket" "s3_artifact_replica" {
  provider = aws.replica
  bucket   = "tf-test-bucket-source-12345"
}

resource "aws_s3_bucket_acl" "s3_artifact_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.s3_artifact_replica.id
  acl      = "private"
}

resource "aws_s3_bucket_versioning" "s3_artifact_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.s3_artifact_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "s3_artifact_replica" {
  provider = aws.replica

  depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.s3_artifact_replica.arn
  bucket = aws_s3_bucket.s3_artifact.id

  rule {
    id = "tf-replication-rule-12345"

    filter {
      prefix = "prefix"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.s3_artifact_replica.arn
      storage_class = "STANDARD"
    }
  }
}
