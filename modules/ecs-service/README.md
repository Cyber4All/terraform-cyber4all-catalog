<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.2.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 4.36)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 4.36)

## Resources

The following resources are used by this module:

- [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) (resource)
- [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) (resource)
- [aws_service_discovery_service.registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn)

Description: ARN of an ECS cluster.

Type: `string`

### <a name="input_dns_namespace_id"></a> [dns\_namespace\_id](#input\_dns\_namespace\_id)

Description: The ID of the namespace to use for DNS configuration.

Type: `string`

### <a name="input_image"></a> [image](#input\_image)

Description: The image used to start a container. This string is passed directly to the Docker daemon. Images in the Docker Hub registry are available by default. You can also specify other repositories with either `repository-url/image:tag` or `repository-url/image@digest`. Up to 255 letters (uppercase and lowercase), numbers, hyphens, underscores, colons, periods, forward slashes, and number signs are allowed.

Type: `string`

### <a name="input_service_name"></a> [service\_name](#input\_service\_name)

Description: Name that will associate all resources.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu)

Description: The hard limit of CPU units to present for the task. For tasks that use the Fargate launch type (both Linux and Windows containers), this field is required.

Type: `number`

Default: `256`

### <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory)

Description: The amount (in MiB) of memory to present to the container. [container\_definition\_memory](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_memory)

Type: `number`

Default: `256`

### <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture)

Description: Must be set to either `X86_64` or `ARM64`; see cpu architecture.

Type: `string`

Default: `null`

### <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count)

Description: Number of instances of the task definition to place and keep running. Defaults to 1. Do not specify if using the `DAEMON` scheduling strategy.

Type: `number`

Default: `1`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: The environment variables to pass to a container. This parameter maps to the --env option to docker run. Consists (name, value)

Type: `list(any)`

Default: `[]`

### <a name="input_environment_files"></a> [environment\_files](#input\_environment\_files)

Description: A list of files containing the environment variables to pass to a container. This parameter maps to the `--env-file` option to `docker run`. Consists (value, type = "s3")

Type: `list(any)`

Default: `[]`

### <a name="input_ephemeral_storage"></a> [ephemeral\_storage](#input\_ephemeral\_storage)

Description: Ephemeral storage block, consists (size\_in\_gib): The minimum supported value is `21` GiB and the maximum supported value is `200` GiB. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate. See main.tf

Type: `map(any)`

Default: `{}`

### <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn)

Description: ARN of task execution role that container or daemon can assume

Type: `string`

Default: `null`

### <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds)

Description: Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers.

Type: `number`

Default: `0`

### <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type)

Description: Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `EC2`.

Type: `string`

Default: `"EC2"`

### <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer)

Description: Configuration block for load balancers. Consists (target\_group\_arn, container\_name, container\_port). See main.tf

Type: `map(any)`

Default: `{}`

### <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration)

Description: Network configuration for the service. This parameter is required for task definitions that use the `awsvpc` network mode to receive their own Elastic Network Interface, and it is not supported for other network modes. Consists (subnets, security\_groups, assign\_public\_ip) see main.tf.

Type: `map(any)`

Default: `{}`

### <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode)

Description: Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`.

Type: `string`

Default: `"bridge"`

### <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family)

Description: If the requires\_compatibilities is `FARGATE` this field is required; must be set to a valid option from the operating system family in the runtime platform setting.

Type: `string`

Default: `null`

### <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings)

Description: Port mappings allow containers to access ports on the host container instance to send or receive traffic. For task definitions that use the `awsvpc` network mode, only specify the containerPort. The `hostPort` can be left blank or it must be the same value as the `containerPort`. Consists (containerPort, hostPort, protocol)

Type: `list(any)`

Default: `[]`

### <a name="input_region"></a> [region](#input\_region)

Description: Aws region for cloud watch logs to exist in.

Type: `string`

Default: `"us-east-1"`

### <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities)

Description: Set of launch types required by the task. The valid values are `EC2` and `FARGATE`.

Type: `list(string)`

Default:

```json
[
  "EC2"
]
```

### <a name="input_secrets"></a> [secrets](#input\_secrets)

Description: An object representing the secret to expose to your container. For more information, see [Passing sensitive data to a container](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html). Consists (name, valueFrom)

Type: `list(any)`

Default: `[]`

### <a name="input_service_discovery_description"></a> [service\_discovery\_description](#input\_service\_discovery\_description)

Description: The description of the service.

Type: `string`

Default: `"Service Discovery Managed by Terraform"`

### <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries)

Description: Service discovery registries for the service. The maximum number of `service_registries` blocks is `1`. Consists (port, container\_name, container\_port). See main.tf

Type: `map(any)`

Default: `{}`

### <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu)

Description: Number of cpu units used by the task. If the `requires_compatibilities` is `FARGATE` this field is required.

Type: `string`

Default: `null`

### <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory)

Description: Amount (in MiB) of memory used for the task. Killed if exceeded. Required if requires\_compatibilities is FARGATE

Type: `string`

Default: `null`

### <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn)

Description: ARN of IAM role that allows containers to make calls to other AWS sevices

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_cluster"></a> [cluster](#output\_cluster)

Description: ARN of cluster which service runs on.

### <a name="output_desired_count"></a> [desired\_count](#output\_desired\_count)

Description: Number of instances of the task definition.

### <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn)

Description: ARN that identifies the service.

### <a name="output_ecs_task_arn"></a> [ecs\_task\_arn](#output\_ecs\_task\_arn)

Description: Full ARN of the Task Definition (including both `family` and `revision`).

### <a name="output_ecs_taskdef_revision"></a> [ecs\_taskdef\_revision](#output\_ecs\_taskdef\_revision)

Description: Revision of the task in a particular family.

### <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role)

Description: ARN of IAM role used for ELB.

### <a name="output_service_discovery_arn"></a> [service\_discovery\_arn](#output\_service\_discovery\_arn)

Description: The ARN of the service.
<!-- END_TF_DOCS -->