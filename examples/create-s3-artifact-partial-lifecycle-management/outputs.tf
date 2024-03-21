output "primary_s3-artifact-id" {
  value = module.s3_artifact.primary_id
}

output "primary_s3-artifact-arn" {
  value = module.s3_artifact.primary_arn
}

output "primary_s3-artifact-domain-name" {
  value = module.s3_artifact.primary_domain_name
}

output "replica_s3-artifact-id" {
  value = module.s3_artifact.replica_id
}

output "replica_s3-artifact-arn" {
  value = module.s3_artifact.replica_arn
}

output "replica_s3-artifact-domain-name" {
  value = module.s3_artifact.replica_domain_name
}
