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
# expiration policy. The full lifecycle management variable is a boolean and is defaulted to true.
#
# The bucket replication configuration creates a bucket in a different region. The replica
# bucket will be encrypted with the same "CMK" as the primary bucket. The replica bucket defines
# a bucket policy that allows the primary bucket to replicate objects to it.
#
# The module includes the following:
#
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
  region = var.priamry_region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE PRIMARY S3 BUCKET

# AND ASSOCIATED RESOURCES (LIFECYCLE MANAGEMENT, VERSIONING).

# ------------------------------------------------------------


# -------------------------------------------
# CREATE PRIMARY S3 BUCKET
# -------------------------------------------

resource "aws_s3_bucket" "primary" {
  bucket = var.primary_bucket_name
}

# -------------------------------------------
# CREATE PRIMARY S3 BUCKET POLICY
# -------------------------------------------

resource "aws_s3_bucket_acl" "primary" {
  bucket = aws_s3_bucket.primary.id
  acl    = var.pimary_bucket_acl
}

# -------------------------------------------
# ENABLE PRIMARY OBJECT VERSIONING
# -------------------------------------------

resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id
  versioning_configuration {
    status = var.bucket_versioning_configuration_status
  }
}

# -------------------------------------------
# CONFIGURE PARTIAL LIFECYCLE MANAGEMENT
# -------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "pirmary" {
  count = !var.enable_storage_lifecycles ? 1 : 0

  bucket = aws_s3_bucket.primary.id

  rule {
    id = var.lifecycle_versioning_id

    status = var.bucket_versioning_configuration_status

    noncurrent_version_expiration {
      noncurrent_days           = 30
      newer_noncurrent_versions = 1
    }
  }
}

# -------------------------------------------
# CONFIGURE FULL LIFECYCLE MANAGEMENT
# -------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "primary" {
  count = var.full_lifecycle_management ? 1 : 0

  bucket = aws_s3_bucket.primary.id

  rule {
    id = var.lifecycle_transitioin_id

    status = var.bucket_versioning_configuration_status

    transition {
      days          = 30
      storage_class = var.transition_30_storage_class
    }

    transition {
      days          = 90
      storage_class = var.transition_90_storage_class
    }

  }

  rule {
    id = var.lifecycle_versioning_id

    status = var.bucket_versioning_configuration_status

    noncurrent_version_expiration {
      noncurrent_days           = 30
      newer_noncurrent_versions = 1
    }
  }
}

# -------------------------------------------
# CONFIGURE PRIMARY S3 BUCKET PUBLIC ACCESS
# -------------------------------------------
resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------
# CONFIGURE PRIMARY S3 BUCKET SERVER SIDE ENCRYPTION
# -------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE THE REPLICA S3 BUCKET

# AND ASSOCIATED RESOURCES (LIFECYCLE MANAGEMENT, VERSIONING).

# ------------------------------------------------------------

# -------------------------------------------
# CREATE S3 REPLICATION BUCKET
# -------------------------------------------

resource "aws_s3_bucket" "replica" {
  provider = aws.replica
  bucket   = var.replica_bucket_name
}

# -------------------------------------------
# CONFIGURE REPLICA S3 BUCKET POLICY
# -------------------------------------------

resource "aws_s3_bucket_acl" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  acl      = var.replica_bucket_acl
}

# -------------------------------------------
# ENABLE REPLICA OBJECT VERSIONING
# -------------------------------------------

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  versioning_configuration {
    status = var.bucket_versioning_configuration_status
  }
}

# -------------------------------------------
# CONFIGURE REPLICA S3 BUCKET PUBLIC ACCESS
# -------------------------------------------

resource "aws_s3_bucket_public_access_block" "replica" {
  bucket = aws_s3_bucket.replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------
# CONFIGURE REPLICA S3 BUCKET SERVER SIDE ENCRYPTION
# -------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# -------------------------------------------
# CREATE BUCKET REPLICATION CONFIGURATION
# -------------------------------------------

resource "aws_s3_bucket_replication_configuration" "replica" {
  provider = aws.replica

  depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replica.arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id = var.bucket_replication_configuration_rule_id

    status = var.replica_configuration_status

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = var.replica_configuration_destination_storage_class
    }
  }
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE IAM POLICY CONFIGURATION

# FOR THE PRIMARY BUCKET (POLICY DOCUMENT, IAM ROLE).

# ------------------------------------------------------------

# -------------------------------------------
# IAM ROLE/POLICY CONFIGURATION FOR PRIMARY
# -------------------------------------------

data "aws_iam_policy_document" "primary" {
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
# CREATE PRIMARY IAM POLICY
# -------------------------------------------
resource "aws_iam_policy" "primary" {
  name   = "tf-iam-role-policy-replication-12345"
  policy = data.aws_iam_policy_document.primary.json
}


# ------------------------------------------------------------

# THE FOLLOWING SECTION IS USED TO CREATE IAM POLICY CONFIGURATION

# FOR THE REPLICA BUCKET (POLICY DOCUMENT, IAM ROLE).

# ------------------------------------------------------------

# -------------------------------------------
# IAM ROLE/POLICY CONFIGURATION FOR REPLICA
# -------------------------------------------
data "aws_iam_policy_document" "replica" {
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

# -------------------------------------------
# ASSUME ROLE POLICY FOR REPLICA
# -------------------------------------------

resource "aws_iam_role" "replica" {
  name               = "tf-iam-role-replication-12345"
  assume_role_policy = data.aws_iam_policy_document.replica.json
}

# -------------------------------------------
# ATTACH POLICY TO ROLE FOR REPLICA
# -------------------------------------------
resource "aws_iam_role_policy_attachment" "replica" {
  role       = aws_iam_role.replica.name
  policy_arn = aws_iam_policy.primary.arn
}