# Virtual Private Cloud (VPC)

## Overview

This module contains Terraform code to deploy a VPC on [AWS](https://aws.amazon.com/) using [Virtual Private Cloud (VPC)](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html).

The module creates a single VPC with public and private subnets in multiple availability zone. The public subnets are used for resources that need to be publicly accessible, such as load balancers. The private subnets are used for resources that should not be publicly accessible, such as backend APIs.

![Cloud Craft VPC Module Diagram](../../_docs/tf-vpc-module-diagram.png)

## Learn

VPC is a fundamental building block of AWS. It allows you to create a virtual network in the cloud that is isolated from other virtual networks. You can then launch AWS resources, such as ECS cluster, into your VPC. You can also connect your VPC to databases deployed in a different VPC using [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html).

To learn more about VPC, see the following resources:
- [VPC Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html#subnet-basics)
- [VPC Routing](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)
- [VPC NACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
- [VPC NAT Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html)
