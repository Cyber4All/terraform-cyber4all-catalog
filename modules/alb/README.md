# Application Load Balancer (ALB)

## Overview

This module contains the Terraform code to deploy an ALB on [AWS](https://aws.amazon.com/) using [Elastic Load Balancing (ELB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html).

<!-- Image or Arch diagram -->
![CloudCraft ALB Diagram](../../_docs/tf-alb-module-diagram.png)

## Learn

Elastic Load Balancing automatically distributes your incoming traffic across multiple targets, such as EC2 instances, containers, and IP addresses, in one or more Availability Zones. It monitors the health of its registered targets, and routes traffic only to the healthy targets. Elastic Load Balancing scales your load balancer as your incoming traffic changes over time. It can automatically scale to the vast majority of workloads.

For more information about when and why ALBs should be used review the [Application Load Balancer Overview](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html#application-load-balancer-overview).

The module is developed to support HTTP/HTTPS traffic to a target. The module creates the listeners and DNS records that can be used to route traffic to the ALB. It is the responsibility of the user to create and manage the target group and targets that the ALB will route traffic to. The targets can be associated to the listeners using listeners rules.

Additional recommended readings include:

- [Listener and Listener Rules](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
- [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
- [ALB Access Logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
- [Troubleshooting ALB](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-troubleshooting.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)
## Sample Usage
```hcl
terraform {
	 source = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"
}

inputs = {


  	 # --------------------------------------------
  	 # Required variables
  	 # --------------------------------------------
  

    	 alb_name  = string
    

    	 vpc_id  = string
    

    	 vpc_subnet_ids  = list(string)
    

  	 # --------------------------------------------
  	 # Optional variables
  	 # --------------------------------------------
  

    	 dns_record_prefix  = string
    

    	 enable_https_listener  = bool
    

    	 hosted_zone_name  = string
    

}
```
## Required Inputs

The following input variables are required:

### <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name)

Description: The name of the ALB.

Type: `string`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: The VPC ID where the ALB will be created.

Type: `string`

### <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids)

Description: The ids of the subnets that the ALB can use to source its IP.

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dns_record_prefix"></a> [dns\_record\_prefix](#input\_dns\_record\_prefix)

Description: The prefix of the DNS A record that will be created for the ALB.

Type: `string`

Default: `"api"`

### <a name="input_enable_https_listener"></a> [enable\_https\_listener](#input\_enable\_https\_listener)

Description: Creates an HTTPS listener for the ALB. When enabled the ALB will redirect HTTP traffic to HTTPS automatically.

Type: `bool`

Default: `true`

### <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name)

Description: The name of the hosted zone where the ALB DNS record will be created.

Type: `string`

Default: `""`
## Outputs

The following outputs are exported:

### <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn)

Description: The ARN of the ALB.

### <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name)

Description: The DNS name of the ALB.

### <a name="output_alb_dns_record_name"></a> [alb\_dns\_record\_name](#output\_alb\_dns\_record\_name)

Description: The name of the ALB DNS record.

### <a name="output_alb_hosted_zone_id"></a> [alb\_hosted\_zone\_id](#output\_alb\_hosted\_zone\_id)

Description: The ID of the hosted zone where the ALB DNS record was created.

### <a name="output_alb_name"></a> [alb\_name](#output\_alb\_name)

Description: The name of the ALB.

### <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id)

Description: The ID of the ALB security group.

### <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn)

Description: The ARN of the HTTP listener.

### <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn)

Description: The ARN of the HTTPS listener.
<!-- END_TF_DOCS -->