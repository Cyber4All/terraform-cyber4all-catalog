# Convienient outputs from other modules that can be used
# during the testing of the ecs-service module.

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = module.alb.alb_dns_name
}

output "alb_name" {
  description = "The name of the ALB."
  value       = module.alb.alb_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.cluster.ecs_cluster_name
}


# Outputs from the internal instance of the
# ecs-service module.

output "internal_ecs_task_container_port" {
  description = "The port that is exposed by the ECS task's container."
  value       = module.internal-ecs-service.ecs_task_container_port
}

output "internal_ecs_task_definition_arn" {
  description = "The full ARN of the task definition that is deployed."
  value       = module.internal-ecs-service.ecs_task_definition_arn
}

output "internal_ecs_task_essential_image" {
  description = "The image that is deployed."
  value       = module.internal-ecs-service.ecs_task_essential_image
}

output "internal_ecs_task_execution_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task execution."
  value       = module.internal-ecs-service.ecs_task_execution_iam_role_arn
}

output "internal_ecs_task_execution_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task execution."
  value       = module.internal-ecs-service.ecs_task_execution_iam_role_name
}

output "internal_ecs_task_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task."
  value       = module.internal-ecs-service.ecs_task_iam_role_arn
}

output "internal_ecs_task_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task."
  value       = module.internal-ecs-service.ecs_task_iam_role_name
}

output "internal_ecs_task_log_group_arn" {
  description = "The ARN of the CloudWatch log group that is used for the ECS task."
  value       = module.internal-ecs-service.ecs_task_log_group_arn
}

output "internal_ecs_task_log_group_name" {
  description = "The name of the CloudWatch log group that is used for the ECS task."
  value       = module.internal-ecs-service.ecs_task_log_group_name
}

output "internal_service_auto_scaling_alarm_arns" {
  description = "The ARNs of the CloudWatch alarms that are used for the ECS service's Auto Scaling."
  value       = module.internal-ecs-service.service_auto_scaling_alarm_arns
}

output "internal_service_arn" {
  description = "The ARN of the ECS service."
  value       = module.internal-ecs-service.service_arn
}

output "internal_service_elb_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS service's ELB."
  value       = module.internal-ecs-service.service_elb_iam_role_arn
}

output "internal_service_name" {
  description = "The name of the ECS service."
  value       = module.internal-ecs-service.service_name
}

output "internal_service_target_group_arn" {
  description = "The ARN of the load balancing target group."
  value       = module.internal-ecs-service.service_target_group_arn
}

output "internal_service_target_group_name" {
  description = "The name of the load balancing target group."
  value       = module.internal-ecs-service.service_target_group_name
}

output "internal_service_target_group_arn_suffix" {
  description = "The load balancing target group's ARN suffix to use with CloudWatch Metrics."
  value       = module.internal-ecs-service.service_target_group_arn_suffix
}


# Outputs from the internal instance of the
# ecs-service module.

output "external_ecs_task_container_port" {
  description = "The port that is exposed by the ECS task's container."
  value       = module.external-ecs-service.ecs_task_container_port
}

output "external_ecs_task_definition_arn" {
  description = "The full ARN of the task definition that is deployed."
  value       = module.external-ecs-service.ecs_task_definition_arn
}

output "external_ecs_task_essential_image" {
  description = "The image that is deployed."
  value       = module.external-ecs-service.ecs_task_essential_image
}

output "external_ecs_task_execution_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task execution."
  value       = module.external-ecs-service.ecs_task_execution_iam_role_arn
}

output "external_ecs_task_execution_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task execution."
  value       = module.external-ecs-service.ecs_task_execution_iam_role_name
}

output "external_ecs_task_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task."
  value       = module.external-ecs-service.ecs_task_iam_role_arn
}

output "external_ecs_task_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task."
  value       = module.external-ecs-service.ecs_task_iam_role_name
}

output "external_ecs_task_log_group_arn" {
  description = "The ARN of the CloudWatch log group that is used for the ECS task."
  value       = module.external-ecs-service.ecs_task_log_group_arn
}

output "external_ecs_task_log_group_name" {
  description = "The name of the CloudWatch log group that is used for the ECS task."
  value       = module.external-ecs-service.ecs_task_log_group_name
}

output "external_service_auto_scaling_alarm_arns" {
  description = "The ARNs of the CloudWatch alarms that are used for the ECS service's Auto Scaling."
  value       = module.external-ecs-service.service_auto_scaling_alarm_arns
}

output "external_service_arn" {
  description = "The ARN of the ECS service."
  value       = module.external-ecs-service.service_arn
}

output "external_service_elb_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS service's ELB."
  value       = module.external-ecs-service.service_elb_iam_role_arn
}

output "external_service_name" {
  description = "The name of the ECS service."
  value       = module.external-ecs-service.service_name
}

output "external_service_target_group_arn" {
  description = "The ARN of the load balancing target group."
  value       = module.external-ecs-service.service_target_group_arn
}

output "external_service_target_group_name" {
  description = "The name of the load balancing target group."
  value       = module.external-ecs-service.service_target_group_name
}

output "external_service_target_group_arn_suffix" {
  description = "The load balancing target group's ARN suffix to use with CloudWatch Metrics."
  value       = module.external-ecs-service.service_target_group_arn_suffix
}
