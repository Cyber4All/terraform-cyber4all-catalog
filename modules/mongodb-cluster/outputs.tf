output "cluster_id" {
  description = "The mongodb cluster ID"
  value       = mongodbatlas_cluster.cluster.cluster_id
}

output "cluster_mongodb_version" {
  description = "The mongodb cluster version"
  value       = mongodbatlas_cluster.cluster.mongo_db_version
}

output "cluster_mongodb_base_uri" {
  description = "The base connection string for the cluster. The field is available only when the cluster is in an operational state."
  value       = mongodbatlas_cluster.cluster.mongo_uri
}

output "cluster_mongodb_uri_with_options" {
  description = "The connection string for the cluster with replicaSet, ssl, and authSource query parameters with values appropriate for the cluster. The field is available only when the cluster is in an operational state."
  value       = mongodbatlas_cluster.cluster.mongo_uri_with_options
}

output "cluster_state" {
  description = "The state that the cluster is in. Possible values are: IDLE, CREATING, UPDATING, DELETING, DELETED, REPAIRING."
  value       = mongodbatlas_cluster.cluster.state_name
}
