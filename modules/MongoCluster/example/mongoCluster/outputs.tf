output "srv" {
  description = "The SRV of the cluster"
  value       = mongodbatlas_cluster.cluster-test.connection_strings[0].standard_srv
}