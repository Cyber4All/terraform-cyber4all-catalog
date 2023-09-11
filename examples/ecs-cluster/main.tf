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

  azs            = [for letter in ["a", "b", "c"] : "${var.region}${letter}"]
  public_subnets = [for i in range(0, 3) : "10.0.${i}.0/24"]
}

module "cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = "cluster-test${var.random_id}"

  # AMI Name: amzn2-ami-ecs-hvm-2.0.20230809-x86_64-ebs
  cluster_instance_ami = "ami-0f844a9675b22ea32"

  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = module.vpc.public_subnets
  cluster_ingress_access_ports = [
    {
      from_port = 80
      to_port   = 80
      cidr_ipv4 = "0.0.0.0/0"
    }
  ]

  cluster_max_size = 2
}
