output "authorized_iam_users" {
  description = "The list of IAM users authorized to access the project."
  value       = keys(mongodbatlas_database_user.user)
}

output "authorized_iam_roles" {
  description = "The list of IAM roles authorized to access the project."
  value       = keys(mongodbatlas_database_user.role)

}

output "peering_route_table_ids" {
  description = "The list of peering route table IDs."
  value       = var.enable_vpc_peering ? local.route_table_ids : []
}
