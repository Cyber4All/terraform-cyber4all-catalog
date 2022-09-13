module "cyber4all-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

//all below are optional and can be found at
//https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.14.4?tab=inputs
  name = "cyber4all-vpc"
  azs  = [ "us-east-1a" ]
  cidr = var.cidr

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  single_nat_gateway = true

  create_egress_only_igw = true
}