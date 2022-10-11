<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (4.29.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_ecs_service.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) (resource)
- [aws_ecs_task_definition.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_ecs_service_cluster_arn"></a> [ecs\_service\_cluster\_arn](#input\_ecs\_service\_cluster\_arn)

Description: The ARN of the cluster where the service will be located

Type: `string`

### <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name)

Description: The name of the service

Type: `string`

### <a name="input_ecs_service_num_tasks"></a> [ecs\_service\_num\_tasks](#input\_ecs\_service\_num\_tasks)

Description: The number of instances of the given task definition to place and run

Type: `number`

### <a name="input_ecs_service_private_subnets"></a> [ecs\_service\_private\_subnets](#input\_ecs\_service\_private\_subnets)

Description: The list of private subnets from the vpc

Type: `list(string)`

### <a name="input_ecs_service_public_subnets"></a> [ecs\_service\_public\_subnets](#input\_ecs\_service\_public\_subnets)

Description: The list of public subnets from the vpc

Type: `list(string)`

### <a name="input_ecs_service_security_group_id"></a> [ecs\_service\_security\_group\_id](#input\_ecs\_service\_security\_group\_id)

Description: The id of the security group created

Type: `string`

### <a name="input_ecs_taskdef_container_definitions"></a> [ecs\_taskdef\_container\_definitions](#input\_ecs\_taskdef\_container\_definitions)

Description: A list of containers with container definitions provided as a single JSON document

Type: `any`

### <a name="input_ecs_taskdef_family"></a> [ecs\_taskdef\_family](#input\_ecs\_taskdef\_family)

Description: The unique name for the task definition

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_capacity_provider_base"></a> [capacity\_provider\_base](#input\_capacity\_provider\_base)

Description: Minimum number of tasks to run on the capacity provider

Type: `number`

Default: `1`

### <a name="input_capacity_provider_name"></a> [capacity\_provider\_name](#input\_capacity\_provider\_name)

Description: Short name for the capacity provider

Type: `string`

Default: `"example-capacity-provider"`

### <a name="input_capacity_provider_weight"></a> [capacity\_provider\_weight](#input\_capacity\_provider\_weight)

Description: Relative percent of number of launched tasks that use capacity provider

Type: `number`

Default: `1`

### <a name="input_cpu"></a> [cpu](#input\_cpu)

Description: Hard limit of CPU units for the task

Type: `string`

Default: `null`

### <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture)

Description: Specify CPU architecture

Type: `string`

Default: `null`

### <a name="input_credentials_parameter"></a> [credentials\_parameter](#input\_credentials\_parameter)

Description: The authorization credential options

Type: `string`

Default: `null`

### <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type)

Description: Type of deployment controller

Type: `string`

Default: `"ECS"`

### <a name="input_deployment_max_percent"></a> [deployment\_max\_percent](#input\_deployment\_max\_percent)

Description: Percent ceiling limit on num\_tasks running on a service

Type: `number`

Default: `100`

### <a name="input_deployment_min_healthy_percent"></a> [deployment\_min\_healthy\_percent](#input\_deployment\_min\_healthy\_percent)

Description: Base percent of healthy tasks to be run on a service

Type: `number`

Default: `10`

### <a name="input_docker_volume_configuration_autoprovision"></a> [docker\_volume\_configuration\_autoprovision](#input\_docker\_volume\_configuration\_autoprovision)

Description: Determines whether volumes are automatically created if they don't exist. Use only when scope is set to 'shared'.

Type: `bool`

Default: `false`

### <a name="input_docker_volume_configuration_driver"></a> [docker\_volume\_configuration\_driver](#input\_docker\_volume\_configuration\_driver)

Description: Docker volume driver to use. Must match the driver name provided by Docker for task placement

Type: `string`

Default: `null`

### <a name="input_docker_volume_configuration_driver_opts"></a> [docker\_volume\_configuration\_driver\_opts](#input\_docker\_volume\_configuration\_driver\_opts)

Description: Map of Docker driver specific options

Type: `string`

Default: `null`

### <a name="input_docker_volume_configuration_labels"></a> [docker\_volume\_configuration\_labels](#input\_docker\_volume\_configuration\_labels)

Description: Custom metadata to add to the volume

Type: `string`

Default: `null`

### <a name="input_docker_volume_configuration_scope"></a> [docker\_volume\_configuration\_scope](#input\_docker\_volume\_configuration\_scope)

Description: Determines the lifecycle of the volume. If 'task', then lasts until end of task. If 'shared', persists even after task stops.

Type: `string`

Default: `"null"`

### <a name="input_domain"></a> [domain](#input\_domain)

Description: Fully qualified domain name hosted by an AWS Directory Service

Type: `string`

Default: `null`

### <a name="input_ecs_service_placement_constraints_expression"></a> [ecs\_service\_placement\_constraints\_expression](#input\_ecs\_service\_placement\_constraints\_expression)

Description: Cluster Query Language expression to apply the constraint

Type: `string`

Default: `null`

### <a name="input_ecs_service_placement_constraints_type"></a> [ecs\_service\_placement\_constraints\_type](#input\_ecs\_service\_placement\_constraints\_type)

Description: Type of placement constraint

Type: `string`

Default: `null`

### <a name="input_ecs_service_tags"></a> [ecs\_service\_tags](#input\_ecs\_service\_tags)

Description: Key-value map of resource tags

Type: `any`

Default: `null`

### <a name="input_ecs_taskdef_placement_constraints_expression"></a> [ecs\_taskdef\_placement\_constraints\_expression](#input\_ecs\_taskdef\_placement\_constraints\_expression)

Description: A cluster query language expression to apply to the constraint.

Type: `string`

Default: `null`

### <a name="input_ecs_taskdef_placement_constraints_type"></a> [ecs\_taskdef\_placement\_constraints\_type](#input\_ecs\_taskdef\_placement\_constraints\_type)

Description: Type of constraint. Required if placement\_constraints exists.

Type: `string`

Default: `null`

### <a name="input_ecs_taskdef_tags"></a> [ecs\_taskdef\_tags](#input\_ecs\_taskdef\_tags)

Description: Metadata tags applied to the task def, defined in key-value pairs

Type: `any`

Default: `null`

### <a name="input_efs_volume_configuration_access_point_id"></a> [efs\_volume\_configuration\_access\_point\_id](#input\_efs\_volume\_configuration\_access\_point\_id)

Description: Access Point ID to use

Type: `string`

Default: `null`

### <a name="input_efs_volume_configuration_iam"></a> [efs\_volume\_configuration\_iam](#input\_efs\_volume\_configuration\_iam)

Description: Whether or not to use the Amazon ECS task IAM role defined in a task def

Type: `string`

Default: `"DISABLED"`

### <a name="input_efs_volume_configuration_transit_encryption"></a> [efs\_volume\_configuration\_transit\_encryption](#input\_efs\_volume\_configuration\_transit\_encryption)

Description: Whether or not to enable encryption in transit between ECS host and EFS server

Type: `string`

Default: `null`

### <a name="input_efs_volume_configuration_transit_encryption_port"></a> [efs\_volume\_configuration\_transit\_encryption\_port](#input\_efs\_volume\_configuration\_transit\_encryption\_port)

Description: Port to use when sending data between ECS host and EFS server

Type: `number`

Default: `null`

### <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags)

Description: Specifies whether or not to use ECS managed tags for tasks

Type: `bool`

Default: `false`

### <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command)

Description: Specifies whether or not to use ECS Exec for tasks

Type: `bool`

Default: `false`

### <a name="input_ephemeral_storage_size_in_gib"></a> [ephemeral\_storage\_size\_in\_gib](#input\_ephemeral\_storage\_size\_in\_gib)

Description: Total amount (in GiB) of ephemeral storage to set for the task

Type: `number`

Default: `null`

### <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn)

Description: ARN of task execution role that container or daemon can assume

Type: `string`

Default: `null`

### <a name="input_file_system_id"></a> [file\_system\_id](#input\_file\_system\_id)

Description: ID of the EFS File System OR the Amason FSx for Windows File Serve file system ID to use

Type: `string`

Default: `null`

### <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment)

Description: Specifies whether or not to force a new task deployment of the service. Typically used for updates

Type: `bool`

Default: `false`

### <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds)

Description: Time in seconds to wait until load balancer performs health checks on new tasks

Type: `number`

Default: `0`

### <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role)

Description: Name or ARN of the IAM role

Type: `string`

Default: `null`

### <a name="input_ipc_mode"></a> [ipc\_mode](#input\_ipc\_mode)

Description: IPC resource namespace to be used for the containers in the task

Type: `string`

Default: `"none"`

### <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type)

Description: Service launch type

Type: `string`

Default: `"EC2"`

### <a name="input_load_balancer_container_name"></a> [load\_balancer\_container\_name](#input\_load\_balancer\_container\_name)

Description: The name of the container to associate with load balancer

Type: `string`

Default: `null`

### <a name="input_load_balancer_container_port"></a> [load\_balancer\_container\_port](#input\_load\_balancer\_container\_port)

Description: The port of the container to associate with load balancer

Type: `string`

Default: `null`

### <a name="input_load_balancer_target_group_arn"></a> [load\_balancer\_target\_group\_arn](#input\_load\_balancer\_target\_group\_arn)

Description: ARN of the load balancer

Type: `string`

Default: `null`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: Amount (in MiB) of memory used for the task. Killed if exceeded. Required if requires\_compatibilities is FARGATE

Type: `string`

Default: `null`

### <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode)

Description: Docker networking mode to use for containers in the task

Type: `string`

Default: `"awsvpc"`

### <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family)

Description: Specifies OS family to use

Type: `string`

Default: `null`

### <a name="input_ordered_placement_strategy_field"></a> [ordered\_placement\_strategy\_field](#input\_ordered\_placement\_strategy\_field)

Description: Describes how to use the type of placement strategy

Type: `any`

Default: `null`

### <a name="input_ordered_placement_strategy_type"></a> [ordered\_placement\_strategy\_type](#input\_ordered\_placement\_strategy\_type)

Description: Type of placement strategy

Type: `string`

Default: `"random"`

### <a name="input_pid_mode"></a> [pid\_mode](#input\_pid\_mode)

Description: Process namespace to use for containers in the task

Type: `string`

Default: `null`

### <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags)

Description: Specifies whether to propagate tags from task def or the service to the tasks

Type: `string`

Default: `null`

### <a name="input_proxy_configuration_container_name"></a> [proxy\_configuration\_container\_name](#input\_proxy\_configuration\_container\_name)

Description: The name of the container that serves as the App Mesh Proxy

Type: `string`

Default: `null`

### <a name="input_proxy_configuration_properties"></a> [proxy\_configuration\_properties](#input\_proxy\_configuration\_properties)

Description: The set of network configuration parameters to provide the Container Network Interface

Type:

```hcl
object({
    IgnoredUID         = string       # userID of the proxy container
    IgnoredGID         = string       # groupID of the proxy container
    AppPorts           = list(string) # List of ports that the application uses
    ProxyIngressPort   = number       # Specifies port for incoming traffic to AppPorts
    ProxyEgressPort    = number       # Specifies port for outgoing traffic from AppPorts
    EgressIgnoredPorts = list(string) # List of ports where any outbound traffic going to these ports is ignored and not redirected to ProxyEgressPort. Can be an empty list.
    EgressIgnoredIPs   = list(string) # List of IPs where any outbound traffic going to these ports is ignored and not redirected to ProxyEgressPort. Can be an empty list.
  })
```

Default: `null`

### <a name="input_proxy_configuration_type"></a> [proxy\_configuration\_type](#input\_proxy\_configuration\_type)

Description: The Proxy type

Type: `string`

Default: `"APPMESH"`

### <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities)

Description: Specifies ECS container types

Type: `list(string)`

Default:

```json
[
  "EC2"
]
```

### <a name="input_root_directory"></a> [root\_directory](#input\_root\_directory)

Description: Directory within file system to mount as the root directory

Type: `string`

Default: `null`

### <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy)

Description: Service's scheduling strategy

Type: `string`

Default: `null`

### <a name="input_service_registries_arn"></a> [service\_registries\_arn](#input\_service\_registries\_arn)

Description: ARN of the service registry

Type: `string`

Default: `null`

### <a name="input_service_registries_container_name"></a> [service\_registries\_container\_name](#input\_service\_registries\_container\_name)

Description: Task def container name to be used for service discovery service

Type: `number`

Default: `0`

### <a name="input_service_registries_container_port"></a> [service\_registries\_container\_port](#input\_service\_registries\_container\_port)

Description: Task def port value to be used for service discovery service

Type: `number`

Default: `0`

### <a name="input_service_registries_port"></a> [service\_registries\_port](#input\_service\_registries\_port)

Description: Port value used if service specifies SRV record

Type: `number`

Default: `0`

### <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy)

Description: Whether or not to retain the revision when the original resource is destroyed

Type: `bool`

Default: `false`

### <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn)

Description: ARN of IAM role that allows containers to make calls to other AWS sevices

Type: `string`

Default: `null`

### <a name="input_volume_host_path"></a> [volume\_host\_path](#input\_volume\_host\_path)

Description: Path on the host container instance that is presented to the container

Type: `string`

Default: `null`

### <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name)

Description: name of the volume

Type: `string`

Default: `null`

### <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state)

Description: If true, Terraform waits until service reaches a steady state before continuing

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn)

Description: ARN generated by the service

### <a name="output_ecs_service_cluster"></a> [ecs\_service\_cluster](#output\_ecs\_service\_cluster)

Description: ARN of cluster which service runs on

### <a name="output_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#output\_ecs\_service\_desired\_count)

Description: Number of instances of the task def

### <a name="output_ecs_service_iam_role"></a> [ecs\_service\_iam\_role](#output\_ecs\_service\_iam\_role)

Description: ARN of IAM role used for ELB

### <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name)

Description: Name of the service

### <a name="output_ecs_taskdef_arn"></a> [ecs\_taskdef\_arn](#output\_ecs\_taskdef\_arn)

Description: ARN generated by the task definition

### <a name="output_ecs_taskdef_revision"></a> [ecs\_taskdef\_revision](#output\_ecs\_taskdef\_revision)

Description: Revision of the task in a particular family

### <a name="output_ecs_taskdef_tags"></a> [ecs\_taskdef\_tags](#output\_ecs\_taskdef\_tags)

Description: Map of tags assigned to task definition
<!-- END_TF_DOCS -->