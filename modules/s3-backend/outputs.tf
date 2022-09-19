output "bucket_name" {
  value = aws_s3_bucket.backend.bucket
}

output "bucket_region" {
  value = aws_s3_bucket.backend.region
}