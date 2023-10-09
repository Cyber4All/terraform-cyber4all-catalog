
output "route_table_ids" {
  value = local.route_table_ids
}

output "vpc_id_to_peering_connection_id" {
  value = local.vpc_id_to_peering_connection_id
}

output "vpc_id_to_peering_connection_cidr_block" {
  value = local.vpc_id_to_peering_connection_cidr_block
}

output "route_table_id_to_vpc_id" {
  value = local.route_table_id_to_vpc_id
}

output "route_list" {
  value = local.route_list
}
