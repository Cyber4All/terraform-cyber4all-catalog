# Spacelift Stack

## Overview

This module is designed to create a stack and its supporting resources, enabling an opinionated Continuous Integration/Continuous Deployment (CICD) workflow on Spacelift. It provides the capability to create a Spacelift stack and optionally set up an IAM role for integration with AWS.

![Spacelift Diagram](../../_docs/tf-spacelift-stack.png)

## Learn

This section will help you learn about the resources that are created by this module.

### Stack

A `Stack` is a fundamental resource within Spacelift, serving as a combination of source code, the current state of managed infrastructure (e.g., Terraform state files), and configuration in the form of environment variables and mounted files. Stacks are uniquely named per account, and it's recommended to follow a naming convention like `<environment>-<project>-<module>-<region>`. For instance, `dev-competency-vpc-us-east-1` or `dev-competency-api-ecs-service-us-east-1`. You have the flexibility to create a stack with or without state management. If state management is enabled, Spacelift will handle the storage of the Terraform state file. However, if state management is disabled, you should define an alternative remote backend, such as Amazon S3.

One powerful feature of Spacelift is the ability to define stack dependencies. This allows you to establish a dependency on another stack and reference its outputs. For instance, you can create a stack that relies on a VPC stack and references the VPC ID output from that stack. This module supports defining stack dependencies by providing a map of stack IDs and a map of environment variables linked to outputs from the referenced stack. For example, { "stack-id" = { "vpc_id" = "vpc_id" } }. The input name is automatically prefixed with `TF_VAR_`, which takes the output `vpc_id` from the stack with ID `stack-id` and sets it as an environment variable named `TF_VAR_vpc_id` for the stack you're managing. If the stack you depend on gets updated, it automatically triggers a run of the stack that relies on it.

For more in-depth information, you can refer to the[Spacelift stack documentation](https://docs.spacelift.io/concepts/stack/).

#### Admin Stack vs. Non-Admin Stack

An "admin stack" is a Spacelift stack with the capability to manage other stacks. This is particularly useful when defining a stack responsible for managing multiple stacks. You can create an admin stack by setting the `enable_admin_stack` variable to `true`. When an admin stack is created, it gains the authority to oversee other stacks.

A typical use case for an admin stack is to create a folder with a Terraform file for each stack you want the admin stack to manage. Then, implement the admin stack in a separate folder. You should provision the admin stack first, and it will automatically provision the other stacks it manages. This approach is beneficial when multiple stacks are needed to manage a single project. Ideally, there should be one admin stack per project per environment.

##### Organizing Stacks in Repository

To maintain a well-organized repository, consider arranging your stacks in a logical structure that aligns with your project's needs. A recommended approach is to create a dedicated folder for each stack and place the Terraform files for that stack within the corresponding folder. For example, if you have a project named `competency` and you need stacks for the `VPC`, `ECS service`, and ECS task definition, you can organize the stacks as follows:

```console
live/
	|- environment/
		|- spacelift/
			|- project/
				|- admin/
					|- backend.tf
					|- main.tf
					|- outputs.tf
				|- stacks/
					|- backend.tf
					|- gateway-ecs-service-us-east-1.tf
					|- api-ecs-service-us-east-1.tf
					|- vpc-us-east-1.tf
					|- alb-us-east-1.tf
					|- outputs.tf
```

### Additional Resources

[Why use Spacelift with Terraform?](https://docs.spacelift.io/vendors/terraform/)
