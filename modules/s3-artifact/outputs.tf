output "primary_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.primary.id
}

output "primary_arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.primary.arn
}

output "primary_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.primary.bucket_domain_name
}

output "replica_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.replica[*].id
}

output "replica_arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.replica[*].arn
}

output "replica_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.replica[*].bucket_domain_name
}
