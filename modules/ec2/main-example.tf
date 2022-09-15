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
    key    = "live/example/ec2/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "competency-service-terraform-locks"
    encrypt        = true
  }
}

#################################
# vpc
#################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "example-vpc"
  cidr = "10.99.0.0/18"

  azs              = ["us-east-1a", "us-east-1b"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24"]

}


#################################
# security group
#################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "example-security-group"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

}

#################################
# ec2 
#################################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name          = "example-ec2-instance"
  ami           = "ami-08d4ac5b634553e16" #ubuntu 20.04 LTS
  instance_type = "t2.micro"

  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  placement_group             = "cluster"
  associate_public_ip_address = true

}