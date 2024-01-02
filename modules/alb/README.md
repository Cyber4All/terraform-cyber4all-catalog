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
