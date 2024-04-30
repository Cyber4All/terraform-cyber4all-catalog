# -------------------------------------------------------------------------------------
# S3 ARTIFACTS MODULE
# 
# This module will create an S3 Bucket that supports lifecycle management,
# server side encryption configuration, and bucket replication configuration.
#
# Full lifecycle management by default enables both object versioning and storage transitions.
# Object versioning is enabled with a 30 day noncurrent version expiration policy and transitions
# are enabled with a 30 day transition to STANDARD_IA and a 90 day transition to GLACIER.
# Partial lifecycle management enables only object versioning with a 30 day noncurrent version
# expiration policy. The variable enable_storage_class_transition is a boolean and is defaulted to true.
#
# The bucket replication configuration creates a bucket in a different region. The replica
# bucket will be encrypted with the same "kms" as the primary bucket. The replica bucket defines
# a bucket policy that allows the primary bucket to replicate objects to it. The default storage
# class for the replica bucket is GLACIER. The variable enable_replica is a boolean and is defaulted
# to true.
#
# The module includes the following:
#
# - Primary AWS Provider
# - Replica AWS Provider
# - Primary S3 Bucket
# - Primary S3 Bucket ACL
# - Primary S3 Bucket Versioning
# - Primary S3 Bucket Lifecycle Management (Full or Partial)
# - Primary S3 Bucket Public Access Configuration
# - Primary S3 Bucket Server Side Encryption Configuration
# - Replica S3 Bucket
# - Replica S3 Bucket ACL
# - Replica S3 Bucket Versioning
# - Replica S3 Bucket Public Access Configuration
# - Replica S3 Bucket Server Side Encryption Configuration
# - Replica S3 Bucket Replication Configuration
# - Primary IAM Policy Document
# - Primary IAM Policy
# - Replica IAM Policy Document
# - Replica IAM Role
# - Replica IAM Role Policy Attachment
#
# -------------------------------------------------------------------------------------


# -------------------------------------------
# SET TERRAFORM REQUIREMENTS TO RUN MODULE
# -------------------------------------------

terraform {
  required_version = ">= 1.5.5"

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
  region = var.primary_region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}


# -------------------------------------------
# RETRIEVE GENERAL AWS INFORMATION
# -------------------------------------------

data "aws_canonical_user_id" "current" {}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE PRIMARY S3 BUCKET

# AND ASSOCIATED RESOURCES (LIFECYCLE MANAGEMENT, VERSIONING).

# ------------------------------------------------------------


# -------------------------------------------
# CREATE PRIMARY S3 BUCKET
# -------------------------------------------

resource "aws_s3_bucket" "primary" {
  bucket = var.bucket_name
}

# -------------------------------------------
# CONFIGURE PRIMARY S3 BUCKET OWNERSHIP CONTROLS
# -------------------------------------------
resource "aws_s3_bucket_ownership_controls" "primary" {
  bucket = aws_s3_bucket.primary.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# -------------------------------------------
# CREATE PRIMARY S3 BUCKET ACL
# -------------------------------------------
// this and ownership controls need to be dynamic
resource "aws_s3_bucket_acl" "primary" {
  bucket = aws_s3_bucket.primary.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }

  depends_on = [aws_s3_bucket_ownership_controls.primary]
}

# -------------------------------------------
# ENABLE PRIMARY OBJECT VERSIONING
# -------------------------------------------

resource "aws_s3_bucket_versioning" "primary" {

  bucket = aws_s3_bucket.primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------------------------
# CONFIGURE LIFECYCLE MANAGEMENT
# -------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  dynamic "rule" {
    for_each = var.enable_storage_class_transition ? [1] : []

    content {
      id = "${var.bucket_name}-downgrade-storage-class"

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
  }

  rule {
    id = "${var.bucket_name}-expire-noncurrent-versions"

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = 30
      newer_noncurrent_versions = 1
    }
  }
}

# -------------------------------------------
# CONFIGURE PRIMARY S3 BUCKET PUBLIC ACCESS
# -------------------------------------------
// this needs to be dynamic
resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = !var.enable_public_access
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------
# CONFIGURE PRIMARY S3 BUCKET SERVER SIDE ENCRYPTION
# -------------------------------------------
#tfsec:ignore:aws_s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# -------------------------------------------
# CREATE BUCKET REPLICATION CONFIGURATION
# -------------------------------------------

resource "aws_s3_bucket_replication_configuration" "primary" {
  count = var.enable_replica ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id = "${var.bucket_name}-bucket-replication-rule"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica[0].arn
      storage_class = "GLACIER"
    }
  }

  depends_on = [aws_s3_bucket_versioning.primary]
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE REPLICA S3 BUCKET

# AND ASSOCIATED RESOURCES (LIFECYCLE MANAGEMENT, VERSIONING).

# ------------------------------------------------------------

# -------------------------------------------
# CREATE S3 REPLICATION BUCKET
# -------------------------------------------

resource "aws_s3_bucket" "replica" {
  count = var.enable_replica ? 1 : 0

  provider = aws.replica
  bucket   = "replica-${var.bucket_name}"
}

# -------------------------------------------
# ENABLE REPLICA OBJECT VERSIONING
# -------------------------------------------

resource "aws_s3_bucket_versioning" "replica" {
  count = var.enable_replica ? 1 : 0

  provider = aws.replica
  bucket   = aws_s3_bucket.replica[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------------------------
# CONFIGURE REPLICA S3 BUCKET PUBLIC ACCESS
# -------------------------------------------

resource "aws_s3_bucket_public_access_block" "replica" {
  count = var.enable_replica ? 1 : 0

  bucket                  = aws_s3_bucket.replica[count.index].id
  provider                = aws.replica
  block_public_acls       = true
  block_public_policy     = !var.enable_public_access
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------
# CONFIGURE REPLICA S3 BUCKET SERVER SIDE ENCRYPTION
# -------------------------------------------

#tfsec:ignore:aws_s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  count = var.enable_replica ? 1 : 0

  provider = aws.replica
  bucket   = aws_s3_bucket.replica[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE IAM POLICY CONFIGURATION

# FOR THE REPLICA BUCKET (POLICY DOCUMENT, IAM ROLE).

# ------------------------------------------------------------

# -------------------------------------------
# IAM POLICY CONFIGURATION FOR REPLICA TO ASSUME ROLE
# -------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# -------------------------------------------
# IAM POLICY CONFIGURATION FOR PRIMARY TO REPLICATE TO REPLICA
# -------------------------------------------
data "aws_iam_policy_document" "replication" {
  count = var.enable_replica ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.primary.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.primary.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.replica[count.index].arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  count = var.enable_replica ? 1 : 0

  name        = "${var.bucket_name}-iam-policy-primary"
  description = "Bucket policy for replication configuration"
  policy      = data.aws_iam_policy_document.replication[0].json
}

# -------------------------------------------
# ATTACH POLICY TO ROLE FOR REPLICATION CONFIGURATION
# -------------------------------------------
resource "aws_iam_role_policy_attachment" "replication" {
  count = var.enable_replica ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

# -------------------------------------------
# ASSUME IAM ROLE POLICY FOR REPLICATION CONFIGURATION
# -------------------------------------------

resource "aws_iam_role" "replication" {
  count = var.enable_replica ? 1 : 0

  name               = "${var.bucket_name}-iam-role-primary"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
