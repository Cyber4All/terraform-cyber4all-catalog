output "bucket_name" {
  description = "Name of S3 bucket"
  value = aws_s3_bucket.backend.bucket
}

output "bucket_region" {
  description = "AWS region S3 bucket is in"
  value = aws_s3_bucket.backend.region
}

output "s3_backend_policy_arn" {
  description = "ARN of IAM policy"
  value = aws_iam_policy.tf_s3_backend_policy.arn
}

output "s3_backend_policy_name" {
  description = "Name of IAM policy"
  value = aws_iam_policy.tf_s3_backend_policy.name
}

output "s3_backend_role_arn" {
  description = "ARN of IAM role"
  value = module.iam_assumable_role.iam_role_arn
}

output "s3_backend_role_name" {
  description = "Name of IAM role"
  value = module.iam_assumable_role.iam_role_name
}
