terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "ecs-cluster-test${var.random_id}"
  cidr = "10.0.0.0/16"

  azs             = [for letter in ["a", "b", "c"] : "${var.region}${letter}"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
}

module "cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = "cluster-test${var.random_id}"

  cluster_instance_ami = var.cluster_instance_ami

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.private_subnets

  cluster_max_size = 2
}
