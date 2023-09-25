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

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.5)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

## Sample Usage

```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"


	 # --------------------------------------------
	 # Required variables
	 # --------------------------------------------


	 # The name of the ECS cluster to deploy the ECS service onto.
	 ecs_cluster_name  = string


	 # The name of the ECS service to create.
	 ecs_service_name  = string


	 # --------------------------------------------
	 # Optional variables
	 # --------------------------------------------


	 # Percentage for the target tracking scaling threshold for the ECS Service average CPU utiliziation.
	 cpu_utilization_threshold  = number


	 # The ECS task should be deployed as a scheduled task rather than a managed ECS service.
	 create_scheduled_task  = bool


	 # The number of instances of the ECS service or scheduled task to run across the ECS cluster.
	 desired_number_of_tasks  = number


	 # The ARN of the AWS Secrets Manager secret containing the Docker credentials.
	 docker_credentials_secret_arn  = string


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


	 # A map of environment variables to pass to the ECS task.
	 environment_variables  = map(string)


	 # The maximum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale beyond this number.
	 max_number_of_tasks  = number


	 # Percentage for the target tracking scaling threshold for the ECS Service average memory utiliziation.
	 memory_utilization_threshold  = number


	 # The minimum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale below this number.
	 min_number_of_tasks  = number


	 # Override the image specified in the ECS container definition with the image specified in the module parameters. On the first apply this value should be set to true to ensure the ECS service is created with the correct image. For following applies this value should be set to false to avoid overriding external application deployments.
	 override_image  = bool


	 # Assign a public IP address to the ECS task.
	 scheduled_task_assign_public_ip  = bool


	 # The cron expression to use for the scheduled task.
	 scheduled_task_cron_expression  = string


	 # The event pattern to use for the scheduled task.
	 scheduled_task_event_pattern  = any


	 # A list of security group IDs to associate with the ECS task. A permissive default security will be used if not specified.
	 scheduled_task_security_group_ids  = list(string)


	 # A list of subnet IDs to associate with the ECS task. A permissive default subnet will be used if not specified.
	 scheduled_task_subnet_ids  = list(string)


	 # A map of secrets to pass to the ECS task. These are environment variables that are sensitive and should not be stored in plain text. Instead they are stored in AWS Secrets Manager and injected at runtime into the ECS task.
	 secrets  = map(string)



}
```
## Required Inputs

The following input variables are required:

### <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name)

Description: The name of the ECS cluster to deploy the ECS service onto.

Type: `string`

### <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name)

Description: The name of the ECS service to create.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_cpu_utilization_threshold"></a> [cpu\_utilization\_threshold](#input\_cpu\_utilization\_threshold)

Description: Percentage for the target tracking scaling threshold for the ECS Service average CPU utiliziation.

Type: `number`

Default: `50`

### <a name="input_create_scheduled_task"></a> [create\_scheduled\_task](#input\_create\_scheduled\_task)

Description: The ECS task should be deployed as a scheduled task rather than a managed ECS service.

Type: `bool`

Default: `false`

### <a name="input_desired_number_of_tasks"></a> [desired\_number\_of\_tasks](#input\_desired\_number\_of\_tasks)

Description: The number of instances of the ECS service or scheduled task to run across the ECS cluster.

Type: `number`

Default: `1`

### <a name="input_docker_credentials_secret_arn"></a> [docker\_credentials\_secret\_arn](#input\_docker\_credentials\_secret\_arn)

Description: The ARN of the AWS Secrets Manager secret containing the Docker credentials.

Type: `string`

Default: `""`

### <a name="input_enable_container_logs"></a> [enable\_container\_logs](#input\_enable\_container\_logs)

Description: Enable container logging to CloudWatch Logs.

Type: `bool`

Default: `false`

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

Default: `false`

### <a name="input_enable_service_connect"></a> [enable\_service\_connect](#input\_enable\_service\_connect)

Description: Enable service discovery for the ECS service.

Type: `bool`

Default: `false`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: A map of environment variables to pass to the ECS task.

Type: `map(string)`

Default: `{}`

### <a name="input_max_number_of_tasks"></a> [max\_number\_of\_tasks](#input\_max\_number\_of\_tasks)

Description: The maximum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale beyond this number.

Type: `number`

Default: `4`

### <a name="input_memory_utilization_threshold"></a> [memory\_utilization\_threshold](#input\_memory\_utilization\_threshold)

Description: Percentage for the target tracking scaling threshold for the ECS Service average memory utiliziation.

Type: `number`

Default: `50`

### <a name="input_min_number_of_tasks"></a> [min\_number\_of\_tasks](#input\_min\_number\_of\_tasks)

Description: The minimum number of instances of the ECS service to run across the ECS cluster. Auto scaling will not scale below this number.

Type: `number`

Default: `1`

### <a name="input_override_image"></a> [override\_image](#input\_override\_image)

Description: Override the image specified in the ECS container definition with the image specified in the module parameters. On the first apply this value should be set to true to ensure the ECS service is created with the correct image. For following applies this value should be set to false to avoid overriding external application deployments.

Type: `bool`

Default: `false`

### <a name="input_scheduled_task_assign_public_ip"></a> [scheduled\_task\_assign\_public\_ip](#input\_scheduled\_task\_assign\_public\_ip)

Description: Assign a public IP address to the ECS task.

Type: `bool`

Default: `true`

### <a name="input_scheduled_task_cron_expression"></a> [scheduled\_task\_cron\_expression](#input\_scheduled\_task\_cron\_expression)

Description: The cron expression to use for the scheduled task.

Type: `string`

Default: `""`

### <a name="input_scheduled_task_event_pattern"></a> [scheduled\_task\_event\_pattern](#input\_scheduled\_task\_event\_pattern)

Description: The event pattern to use for the scheduled task.

Type: `any`

Default: `null`

### <a name="input_scheduled_task_security_group_ids"></a> [scheduled\_task\_security\_group\_ids](#input\_scheduled\_task\_security\_group\_ids)

Description: A list of security group IDs to associate with the ECS task. A permissive default security will be used if not specified.

Type: `list(string)`

Default: `[]`

### <a name="input_scheduled_task_subnet_ids"></a> [scheduled\_task\_subnet\_ids](#input\_scheduled\_task\_subnet\_ids)

Description: A list of subnet IDs to associate with the ECS task. A permissive default subnet will be used if not specified.

Type: `list(string)`

Default: `[]`

### <a name="input_secrets"></a> [secrets](#input\_secrets)

Description: A map of secrets to pass to the ECS task. These are environment variables that are sensitive and should not be stored in plain text. Instead they are stored in AWS Secrets Manager and injected at runtime into the ECS task.

Type: `map(string)`

Default: `{}`

<!-- END_TF_DOCS -->