# ECS Service Examples


## Description

The ECS Terraform module is responsible for creating task definitions defined in a given JSON and creating tasks that will fit within the service.

This module uses other examples including the VPC and the ECS cluster modules to implement the service.

## Usage

Creating a service to run task definitions

### EC2 Instance Considerations

Because this module relies on the EC2 module, make sure to connect the ECS endpoints by creating a `nat_gateway` in the VPC with `egress_with_cidr_blocks` rules set in the cluster module. See the [EC2 README](../ec2/README.md) for more details.
