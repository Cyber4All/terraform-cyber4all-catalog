# Elastic Container Service (ECS) Cluster

## Overview

This module contains Terraform code to deploy an ECS cluster on [AWS](https://aws.amazon.com/) using [Elastic Container Service (ECS)](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html).

This service launches an ECS cluster on top of an Auto Scaling Group that you manage. If you wish to launch an ECS cluster on top of Fargate that is completely managed by AWS, specify the FARGATE provider for ECS services being associated to the cluster. Refer to the section EC2 vs Fargate Launch Types for more information on the differences between the two compute options.

<!-- Image or Arch diagram -->

![Cloud Craft ECS Module Diagram](../../_docs/tf-ecs-cluster-module-diagram.png)

## Learn

<!-- A few references to ECS (documentation, blog, etc...) -->

ECS is an orchestration agent that runs on either EC2 container instances or FARGATE (AWS serverless compute option). Container instances can be created individually, or managed with an Auto Scaling group. For more information about container instance configruation review the [launch container instance documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html).

Cluster auto scaling is configured by the ecs-cluster module. The cluster contains a list of capacity providers. The capacity providers can either be custom EC2 autoscaling groups, or from the set providers, i.e FARGATE. This ecs-cluster module creates an EC2 auto scaling group as the default provider strategy and offers FARGATE as a secondary provider option. The variables for the module can be overriden to update the cluster auto scaling. Prior to setting cluster auto scaling configuration review the [AWS documentation for considerations](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-auto-scaling.html).

Additional recommended readings include:

- [Managing Compute for AWS ECS Clusters with Capacity Providers](https://aws.amazon.com/blogs/containers/managing-compute-for-amazon-ecs-clusters-with-capacity-providers/)
- [Deep Dive on AWS ECS Cluster Auto Scaling](https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/)
