output "availability_zones" {
  value = module.vpc.availability_zones
}

output "nat_gateway_public_ip" {
  value = module.vpc.nat_gateway_public_ip
}

output "num_availability_zones" {
  value = module.vpc.num_availability_zones
}

output "num_nat_gateways" {
  value = module.vpc.num_nat_gateways
}

output "private_subnet_cidr_blocks" {
  value = module.vpc.private_subnet_cidr_blocks
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "private_subnet_route_table_id" {
  value = module.vpc.private_subnet_route_table_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnet_cidr_blocks" {
  value = module.vpc.public_subnet_cidr_blocks
}
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "public_subnet_route_table_id" {
  value = module.vpc.public_subnet_route_table_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnets_network_acl_id" {
  value = module.vpc.public_subnets_network_acl_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_name" {
  value = module.vpc.vpc_name
}
