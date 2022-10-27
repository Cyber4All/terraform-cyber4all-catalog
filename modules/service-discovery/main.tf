# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP (SG) FOR ASG
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = var.name
  description = var.description
  vpc         = var.vpc_id
}