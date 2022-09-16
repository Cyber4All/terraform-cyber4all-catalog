terraform {
  required_version = "1.2.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }

  backend "s3" {
    bucket = "competency-service-terraform-state"
    key    = "live/example/vpc/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "competency-service-terraform-locks"
    encrypt        = true
  }
}

module "cyber4all-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  //all below are optional and can be found at
  //https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.14.4?tab=inputs
  name = "cyber4all-vpc"
  azs  = ["us-east-1a", "us-east-1b"]
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  create_egress_only_igw = true
}