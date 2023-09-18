output "availability_zones" {
  value = local.availability_zones
}
output "nat_gateway_count" {
  value = length(aws_nat_gateway.this)
}
output "nat_gateway_public_ips" {
  value = aws_nat_gateway.this[*].public_ip
}
output "num_availability_zones" {
  value = length(local.availability_zones)
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "private_subnet_cidr_blocks" {
  value = aws_subnet.private[*].cidr_block
}
# output "private_subnet_route_table_ids" {}
# output "private_subnets" {}
# output "private_subnets_route_table_ids" {}
output "public_subnet_cidr_blocks" {
  value = aws_subnet.public[*].cidr_block
}
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "public_subnet_route_table_id" {
  value = aws_route_table.public[0].id
}
# output "public_subnets" {}
# output "public_subnets_network_acl_id" {}
output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}
output "vpc_id" {
  value = aws_vpc.this.id
}
output "vpc_name" {
  value = var.vpc_name
}
# output "vpc_ready" {}
