output "ecs_task_definition_arn" {
  description = "The full ARN of the task definition that is deployed."
  value       = local.task_definition
}

output "ecs_task_essential_image" {
  description = "The image that is deployed."
  value       = local.image
}

output "ecs_task_execution_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task execution."
  value       = aws_iam_role.task_execution.arn
}

output "ecs_task_execution_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task execution."
  value       = aws_iam_role.task_execution.name
}

output "ecs_task_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS task."
  value       = length(var.ecs_task_role_policy_arns) > 0 ? aws_iam_role.task[0].arn : null
}

output "ecs_task_iam_role_name" {
  description = "The name of the IAM role that is used for the ECS task."
  value       = length(var.ecs_task_role_policy_arns) > 0 ? aws_iam_role.task[0].name : null
}

output "ecs_task_log_group_arn" {
  description = "The ARN of the CloudWatch log group that is used for the ECS task."
  value       = var.enable_container_logs ? aws_cloudwatch_log_group.task[0].arn : null
}

output "ecs_task_log_group_name" {
  description = "The name of the CloudWatch log group that is used for the ECS task."
  value       = var.enable_container_logs ? aws_cloudwatch_log_group.task[0].name : null
}

output "ecs_task_event_rule_arn" {
  description = "The ARN of the EventBridge event rule that is used for the scheduled ECS task."
  value       = var.create_scheduled_task ? aws_cloudwatch_event_rule.scheduled[0].arn : null
}

output "ecs_task_event_rule_name" {
  description = "The name of the EventBridge event rule that is used for the scheduled ECS task."
  value       = var.create_scheduled_task ? aws_cloudwatch_event_rule.scheduled[0].name : null
}

output "service_auto_scaling_alarm_arns" {
  description = "The ARNs of the CloudWatch alarms that are used for the ECS service's Auto Scaling."
  value       = var.enable_service_auto_scaling && !var.create_scheduled_task ? aws_appautoscaling_policy.memory[0].alarm_arns : null
}

output "service_arn" {
  description = "The ARN of the ECS service."
  value       = !var.create_scheduled_task ? aws_ecs_service.service[0].id : null
}

output "service_elb_iam_role_arn" {
  description = "The ARN of the IAM role that is used for the ECS service's ELB."
  value       = !var.create_scheduled_task ? aws_ecs_service.service[0].iam_role : null
}

output "service_name" {
  description = "The name of the ECS service."
  value       = !var.create_scheduled_task ? aws_ecs_service.service[0].name : null
}

output "service_target_group_arn" {
  description = "The ARN of the load balancing target group."
  value       = var.enable_load_balancer && !var.create_scheduled_task ? aws_lb_target_group.alb[0].arn : null
}

output "service_target_group_name" {
  description = "The name of the load balancing target group."
  value       = var.enable_load_balancer && !var.create_scheduled_task ? aws_lb_target_group.alb[0].name : null
}

output "service_target_group_arn_suffix" {
  description = "The load balancing target group's ARN suffix to use with CloudWatch Metrics."
  value       = var.enable_load_balancer && !var.create_scheduled_task ? aws_lb_target_group.alb[0].arn_suffix : null
}
