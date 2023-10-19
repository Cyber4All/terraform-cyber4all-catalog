# Amazon ECS Service

## Overview

## Learn

[ECS Rolling Deployment Circuit Breaker](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-circuit-breaker.html)

[ECS Service Autoscaling](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html)
[ECS CloudWatch Metrics Service Utilization](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-metrics.html#service_utilization)
[Great ECS Scaling Best Practices Article](https://nathanpeck.com/amazon-ecs-scaling-best-practices/)

[Cron expressions reference](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cron-expressions.html)
[Rate expression reference](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rate-expressions.html)
[Amazon EventBridge events](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)
[Custom event pattern reference](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events-structure.html)
[ECS service connect](https://aws.amazon.com/blogs/aws/new-amazon-ecs-service-connect-enabling-easy-communication-between-microservices/)
[Service Connect Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-connect-concepts.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.1)

## Sample Usage

```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"


	 # --------------------------------------------
	 # Required variables
	 # --------------------------------------------


	 # The name of the ECS cluster.
	 ecs_cluster_name  = string


	 # The name of the ECS service.
	 ecs_service_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # The percentage for the ECS service's average CPU utilization threshold. The service uses a target tracking scaling policy.
	 auto_scaling_cpu_util_threshold  = number


	 # The maximum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale beyond this number.
	 auto_scaling_max_number_of_tasks  = number


	 # The percentage for the ECS service's average Memory utilization threshold. The service uses a target tracking scaling policy.
	 auto_scaling_memory_util_threshold  = number


	 # The minimum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale below this number.
	 auto_scaling_min_number_of_tasks  = number


	 # The ECS task should be deployed as a scheduled task rather than a managed ECS service.
	 create_scheduled_task  = bool


	 # The number of instances of the ECS service or scheduled task to run across the ECS cluster.
	 desired_number_of_tasks  = number


	 # The ARN of the AWS Secrets Manager secret containing the Docker credentials.
	 docker_credential_secretsmanager_arn  = string


	 # A map of environment variables to set in the ECS container definition. These values should NOT be sensitive.
	 ecs_container_environment_variables  = map(string)


	 # The name and tag of the docker image to use for the ECS essential container definition. If this value is not set, it will try and pull the currently deployed container image. This allows for external application deployments to be managed outside of Terraform. This value is required for initial deployments and when changing the base image (image without the tag).
	 ecs_container_image  = string


	 # The container port that the application is listening on.
	 ecs_container_port  = number


	 # A map of secrets to configure in the ECS container definition. These are environment variables that are sensitive and should not be stored in plain text. Instead they are stored in AWS Secrets Manager and injected at runtime into the ECS task.
	 ecs_container_secrets  = map(string)


	 # Enable container logging to CloudWatch Logs.
	 enable_container_logs  = bool


	 # Enable rollback of a FAILED deployment if a service cannot reach a steady state.
	 enable_deployment_rollback  = bool


	 # Enable a load balancer to create an ALB target for the ECS service that is attached to an existing ALB.
	 enable_load_balancer  = bool


	 # Enable auto scaling of the ECS service.
	 enable_service_auto_scaling  = bool


	 # Enable service discovery for the ECS service.
	 enable_service_connect  = bool


	 # The load balancer listener arn to attach the ECS service to. This value is required when enable_load_balancer is true.
	 lb_listener_arn  = string


	 # The VPC id to deploy the ECS service's load balancer traget group into. Required when enable_load_balancer is true.
	 lb_target_group_vpc_id  = string


	 # Assign a public IP address to the ECS task.
	 scheduled_task_assign_public_ip  = bool


	 # The cron expression to use for the scheduled task. If create scheduled task is true and no event pattern is provided, then the cron is expected.
	 scheduled_task_cron_expression  = string


	 # The event pattern to use for the scheduled task. If create scheduled task is true and no cron expression is provided, then the event pattern is expected.
	 scheduled_task_event_pattern  = any


	 # A list of security group IDs to associate with the ECS task. A permissive default security will be used if not specified.
	 scheduled_task_security_group_ids  = list(string)


	 # A list of subnet IDs to associate with the ECS task. This value is required when create_scheduled_task is true.
	 scheduled_task_subnet_ids  = list(string)



}
```
## Required Inputs

The following input variables are required:

### <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name)

Description: The name of the ECS cluster.

Type: `string`

### <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name)

Description: The name of the ECS service.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_auto_scaling_cpu_util_threshold"></a> [auto\_scaling\_cpu\_util\_threshold](#input\_auto\_scaling\_cpu\_util\_threshold)

Description: The percentage for the ECS service's average CPU utilization threshold. The service uses a target tracking scaling policy.

Type: `number`

Default: `50`

### <a name="input_auto_scaling_max_number_of_tasks"></a> [auto\_scaling\_max\_number\_of\_tasks](#input\_auto\_scaling\_max\_number\_of\_tasks)

Description: The maximum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale beyond this number.

Type: `number`

Default: `4`

### <a name="input_auto_scaling_memory_util_threshold"></a> [auto\_scaling\_memory\_util\_threshold](#input\_auto\_scaling\_memory\_util\_threshold)

Description: The percentage for the ECS service's average Memory utilization threshold. The service uses a target tracking scaling policy.

Type: `number`

Default: `50`

### <a name="input_auto_scaling_min_number_of_tasks"></a> [auto\_scaling\_min\_number\_of\_tasks](#input\_auto\_scaling\_min\_number\_of\_tasks)

Description: The minimum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale below this number.

Type: `number`

Default: `1`

### <a name="input_create_scheduled_task"></a> [create\_scheduled\_task](#input\_create\_scheduled\_task)

Description: The ECS task should be deployed as a scheduled task rather than a managed ECS service.

Type: `bool`

Default: `false`

### <a name="input_desired_number_of_tasks"></a> [desired\_number\_of\_tasks](#input\_desired\_number\_of\_tasks)

Description: The number of instances of the ECS service or scheduled task to run across the ECS cluster.

Type: `number`

Default: `1`

### <a name="input_docker_credential_secretsmanager_arn"></a> [docker\_credential\_secretsmanager\_arn](#input\_docker\_credential\_secretsmanager\_arn)

Description: The ARN of the AWS Secrets Manager secret containing the Docker credentials.

Type: `string`

Default: `""`

### <a name="input_ecs_container_environment_variables"></a> [ecs\_container\_environment\_variables](#input\_ecs\_container\_environment\_variables)

Description: A map of environment variables to set in the ECS container definition. These values should NOT be sensitive.

Type: `map(string)`

Default: `{}`

### <a name="input_ecs_container_image"></a> [ecs\_container\_image](#input\_ecs\_container\_image)

Description: The name and tag of the docker image to use for the ECS essential container definition. If this value is not set, it will try and pull the currently deployed container image. This allows for external application deployments to be managed outside of Terraform. This value is required for initial deployments and when changing the base image (image without the tag).

Type: `string`

Default: `""`

### <a name="input_ecs_container_port"></a> [ecs\_container\_port](#input\_ecs\_container\_port)

Description: The container port that the application is listening on.

Type: `number`

Default: `null`

### <a name="input_ecs_container_secrets"></a> [ecs\_container\_secrets](#input\_ecs\_container\_secrets)

Description: A map of secrets to configure in the ECS container definition. These are environment variables that are sensitive and should not be stored in plain text. Instead they are stored in AWS Secrets Manager and injected at runtime into the ECS task.

Type: `map(string)`

Default: `{}`

### <a name="input_enable_container_logs"></a> [enable\_container\_logs](#input\_enable\_container\_logs)

Description: Enable container logging to CloudWatch Logs.

Type: `bool`

Default: `true`

### <a name="input_enable_deployment_rollback"></a> [enable\_deployment\_rollback](#input\_enable\_deployment\_rollback)

Description: Enable rollback of a FAILED deployment if a service cannot reach a steady state.

Type: `bool`

Default: `true`

### <a name="input_enable_load_balancer"></a> [enable\_load\_balancer](#input\_enable\_load\_balancer)

Description: Enable a load balancer to create an ALB target for the ECS service that is attached to an existing ALB.

Type: `bool`

Default: `false`

### <a name="input_enable_service_auto_scaling"></a> [enable\_service\_auto\_scaling](#input\_enable\_service\_auto\_scaling)

Description: Enable auto scaling of the ECS service.

Type: `bool`

Default: `true`

### <a name="input_enable_service_connect"></a> [enable\_service\_connect](#input\_enable\_service\_connect)

Description: Enable service discovery for the ECS service.

Type: `bool`

Default: `true`

### <a name="input_lb_listener_arn"></a> [lb\_listener\_arn](#input\_lb\_listener\_arn)

Description: The load balancer listener arn to attach the ECS service to. This value is required when enable\_load\_balancer is true.

Type: `string`

Default: `""`

### <a name="input_lb_target_group_vpc_id"></a> [lb\_target\_group\_vpc\_id](#input\_lb\_target\_group\_vpc\_id)

Description: The VPC id to deploy the ECS service's load balancer traget group into. Required when enable\_load\_balancer is true.

Type: `string`

Default: `""`

### <a name="input_scheduled_task_assign_public_ip"></a> [scheduled\_task\_assign\_public\_ip](#input\_scheduled\_task\_assign\_public\_ip)

Description: Assign a public IP address to the ECS task.

Type: `bool`

Default: `true`

### <a name="input_scheduled_task_cron_expression"></a> [scheduled\_task\_cron\_expression](#input\_scheduled\_task\_cron\_expression)

Description: The cron expression to use for the scheduled task. If create scheduled task is true and no event pattern is provided, then the cron is expected.

Type: `string`

Default: `""`

### <a name="input_scheduled_task_event_pattern"></a> [scheduled\_task\_event\_pattern](#input\_scheduled\_task\_event\_pattern)

Description: The event pattern to use for the scheduled task. If create scheduled task is true and no cron expression is provided, then the event pattern is expected.

Type: `any`

Default: `null`

### <a name="input_scheduled_task_security_group_ids"></a> [scheduled\_task\_security\_group\_ids](#input\_scheduled\_task\_security\_group\_ids)

Description: A list of security group IDs to associate with the ECS task. A permissive default security will be used if not specified.

Type: `list(string)`

Default: `[]`

### <a name="input_scheduled_task_subnet_ids"></a> [scheduled\_task\_subnet\_ids](#input\_scheduled\_task\_subnet\_ids)

Description: A list of subnet IDs to associate with the ECS task. This value is required when create\_scheduled\_task is true.

Type: `list(string)`

Default: `[]`

<!-- END_TF_DOCS -->