output "alb_arn" {
  description = "The ARN of the ALB."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = module.alb.alb_dns_name
}

output "alb_name" {
  description = "The name of the ALB."
  value       = module.alb.alb_name
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = module.alb.alb_security_group_id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = module.alb.http_listener_arn
}
output "availability_zones" {
  value = module.vpc.availability_zones
}

output "nat_gateway_public_ip" {
  value = module.vpc.nat_gateway_public_ip
}

output "num_availability_zones" {
  value = module.vpc.num_availability_zones
}

output "num_nat_gateways" {
  value = module.vpc.num_nat_gateways
}

output "private_subnet_cidr_blocks" {
  value = module.vpc.private_subnet_cidr_blocks
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "private_subnet_route_table_id" {
  value = module.vpc.private_subnet_route_table_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnet_cidr_blocks" {
  value = module.vpc.public_subnet_cidr_blocks
}
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "public_subnet_route_table_id" {
  value = module.vpc.public_subnet_route_table_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnets_network_acl_id" {
  value = module.vpc.public_subnets_network_acl_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_name" {
  value = module.vpc.vpc_name
}

output "secret_arns" {
  value = module.secrets-manager.secret_arns
}

output "secret_arn_references" {
  value = module.secrets-manager.secret_arn_references
}

output "secret_names" {
  value = module.secrets-manager.secret_names
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = module.cluster.ecs_cluster_arn
}

output "ecs_cluster_asg_name" {
  description = "The name of the ECS cluster's Auto Scaling Group."
  value       = module.cluster.ecs_cluster_asg_name
}

output "ecs_cluster_capacity_provider_name" {
  description = "The name of the ECS cluster's capacity provider."
  value       = module.cluster.ecs_cluster_capacity_provider_name
}

output "ecs_cluster_launch_template_id" {
  description = "The ID of the ECS cluster's launch template."
  value       = module.cluster.ecs_cluster_launch_template_id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.cluster.ecs_cluster_name
}

output "ecs_cluster_vpc_subnet_ids" {
  description = "The IDs of the ECS cluster's VPC subnets."
  value       = module.cluster.ecs_cluster_vpc_subnet_ids
}

output "ecs_instance_iam_role_arn" {
  description = "The ARN of the IAM role applied to ECS instances."
  value       = module.cluster.ecs_instance_iam_role_arn
}

output "ecs_instance_iam_role_id" {
  description = "The ID of the IAM role applied to ECS instances."
  value       = module.cluster.ecs_instance_iam_role_id
}

output "ecs_instance_iam_role_name" {
  description = "The name of the IAM role applied to ECS instances."
  value       = module.cluster.ecs_instance_iam_role_name
}

output "ecs_instance_security_group_id" {
  description = "The ID of the security group applied to ECS instances."
  value       = module.cluster.ecs_instance_security_group_id
}

output "ecs_task_definition_arn" {
  description = "The full ARN of the task definition that is deployed."
  value       = module.internal-ecs-service.ecs_task_definition_arn
}

output "ecs_task_essential_image" {
  description = "The image that is deployed."
  value       = module.internal-ecs-service.ecs_task_essential_image
}

output "ecs_task_execution_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task execution."
  value       = module.internal-ecs-service.ecs_task_execution_iam_role_arn
}

output "ecs_task_execution_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task execution."
  value       = module.internal-ecs-service.ecs_task_execution_iam_role_name
}

# output "ecs_task_iam_role_arn" {
#     description = "The ARN of the IAM role that is used for the ECS task."
#     value = aws_iam_role.ecs_task.arn
# }

# output "ecs_task_iam_role_name" {
#     description = "The name of the IAM role that is used for the ECS task."
#     value = aws_iam_role.ecs_task.name
# }

output "ecs_task_log_group_arn" {
  description = "The ARN of the CloudWatch log group that is used for the ECS task."
  value       = module.internal-ecs-service.ecs_task_log_group_arn
}

output "ecs_task_log_group_name" {
  description = "The name of the CloudWatch log group that is used for the ECS task."
  value       = module.internal-ecs-service.ecs_task_log_group_name
}

output "ecs_task_event_rule_arn" {
  description = "The ARN of the EventBridge event rule that is used for the scheduled ECS task."
  value       = module.internal-ecs-service.ecs_task_event_rule_arn
}

output "ecs_task_event_rule_name" {
  description = "The name of the EventBridge event rule that is used for the scheduled ECS task."
  value       = module.internal-ecs-service.ecs_task_event_rule_name
}

output "service_auto_scaling_alarm_arns" {
  description = "The ARNs of the CloudWatch alarms that are used for the ECS service's Auto Scaling."
  value       = module.internal-ecs-service.service_auto_scaling_alarm_arns
}

output "service_arn" {
  description = "The ARN of the ECS service."
  value       = module.internal-ecs-service.service_arn
}

output "service_elb_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS service's ELB."
  value       = module.internal-ecs-service.service_elb_iam_role_arn
}

output "service_name" {
  description = "The name of the ECS service."
  value       = module.internal-ecs-service.service_name
}

output "service_target_group_arn" {
  description = "The ARN of the load balancing target group."
  value       = module.internal-ecs-service.service_target_group_arn
}

output "service_target_group_name" {
  description = "The name of the load balancing target group."
  value       = module.internal-ecs-service.service_target_group_name
}

output "service_target_group_arn_suffix" {
  description = "The load balancing target group's ARN suffix to use with CloudWatch Metrics."
  value       = module.internal-ecs-service.service_target_group_arn_suffix
}
