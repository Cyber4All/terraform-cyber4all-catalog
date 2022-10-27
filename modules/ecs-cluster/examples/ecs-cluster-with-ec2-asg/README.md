# Creating an EC2 instance using Cyber4All/terraform-module/modlues/ecs-cluster

## Source:
github.com/Cyber4All/terraform-module/modules/ecs-cluster

### Description:

The ECS module will be responsible for the creation of ECS clusters with an Autoscaling group

### Usage: 
Link a VPC to an ECS-Cluster with ASG and EC2 instances baked in

#### Configuration Consideration

An EC2 instance will not show up in the Cluster if there is no way to connect to ECS endpoints, practically speaking this means ensuring that a nat gateway is created in the VPC with egress_with_cidr_blocks rules set in the cluster module:
```
module "vpc" {
#content excluded for brevity
    create_nat_gateway = true
    single_nat_gateway = true

}

module "ecs-cluster" {
#content excluded for brevity
    egress_with_cidr_blocks = [
        #example rule
        {
        rule        = "all-tcp"
        cidr_blocks = "0.0.0.0/0"
        }
    ]
}
```