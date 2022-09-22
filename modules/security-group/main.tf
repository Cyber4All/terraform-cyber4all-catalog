#################################
# security group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
#################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.project_name}-sg"
  description = var.security_group_description
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = var.ingress_cidr_blocks
  ingress_rules            = var.ingress_rules
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_rules             = var.egress_rules

}