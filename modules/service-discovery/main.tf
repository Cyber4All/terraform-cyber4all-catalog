resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = var.name
  description = var.description
  vpc         = var.vpc_id
}