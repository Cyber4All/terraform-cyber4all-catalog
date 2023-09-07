output "bucket_name" {
  value = module.s3-artifact.id
}

output "bucket_arn" {
  value = module.s3-artifact.arn
}
