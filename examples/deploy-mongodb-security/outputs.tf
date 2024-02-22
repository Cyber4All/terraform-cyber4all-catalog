output "authorized_iam_users" {
  description = "The list of IAM users authorized to access the project."
  value       = module.mongodb-security.authorized_iam_users
}

output "authorized_iam_roles" {
  description = "The list of IAM roles authorized to access the project."
  value       = module.mongodb-security.authorized_iam_roles

}

output "peering_route_table_ids" {
  description = "The list of peering route table IDs."
  value       = module.mongodb-security.peering_route_table_ids
}
