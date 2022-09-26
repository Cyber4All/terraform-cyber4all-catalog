# Creating an EC2 instance using terraform-aws-modules/ec2-instance/aws

An EC2 instance will not show up in the Cluster if there is no way to connect to ECS endpoints, practically speaking this means ensuring that a nat gateway is created in the VPC:
```
create_nat_gateway = true
single_nat_gateway = true
```