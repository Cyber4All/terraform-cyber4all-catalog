
output "route_table_ids" {
  value = module.mongodb.route_table_ids
}

output "vpc_id_to_peering_connection_id" {
  value = module.mongodb.vpc_id_to_peering_connection_id
}

output "vpc_id_to_peering_connection_cidr_block" {
  value = module.mongodb.vpc_id_to_peering_connection_cidr_block
}

output "route_table_id_to_vpc_id" {
  value = module.mongodb.route_table_id_to_vpc_id
}

output "route_list" {
  value = module.mongodb.route_list
}
