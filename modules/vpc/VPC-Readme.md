## Creating a VPC using AWS VPC Module

[This](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) is a link to the docs on how to use their vpc module but an example is also included in this directory

[This](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.14.4?tab=inputs) is a list of all possible inputs for a vpc module

[This](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.14.4?tab=outputs) is a list of outputs which can be defined in the outputs file


[main-example.tf](./main-example.tf) is a simple example which includes:

- azs: availability zone
- cidr: the CIDR block for the VPC
- private_subnets: list of private subnets
- public_subnets: list of public subnets
- single_nat_gateway: single shared nat gateway across all private networks
- create_egress_only_igw: creates egress only igw



