# ----------------------------------------------------
# service discovery service outputs
# ----------------------------------------------------
output "service_discovery_arn" {
  description = "The ARN of the service."
  value = aws_service_discovery_service.registry.arn
}

# ----------------------------------------------------
# ecs task definition outputs
# ----------------------------------------------------
output "ecs_task_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)."
  value       = aws_ecs_task_definition.task.arn
}

output "ecs_taskdef_revision" {
  description = "Revision of the task in a particular family."
  value       = aws_ecs_task_definition.task.revision
}

# ----------------------------------------------------
# ecs service outputs
# ----------------------------------------------------
output "ecs_service_arn" {
  description = "ARN that identifies the service."
  value       = aws_ecs_service.service.id
}

output "cluster" {
  description = "ARN of cluster which service runs on."
  value       = aws_ecs_service.service.cluster
}

output "desired_count" {
  description = "Number of instances of the task definition."
  value       = aws_ecs_service.service.desired_count
}

output "iam_role" {
  description = "ARN of IAM role used for ELB."
  value       = aws_ecs_service.service.iam_role
}
