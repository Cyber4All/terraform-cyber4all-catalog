# ----------------------------------------------------
# ecs cluster outputs
# ----------------------------------------------------

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs.cluster_arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs.cluster_name
}

# ----------------------------------------------------
# auto scaling group outputs
# ----------------------------------------------------

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.autoscaling.launch_template_id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.autoscaling.launch_template_arn
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.autoscaling.launch_template_latest_version
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.autoscaling.autoscaling_group_id
}
output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.autoscaling.autoscaling_group_arn
}

output "autoscaling_group_availability_zones" {
  description = "The availability zones of the autoscale group"
  value       = module.autoscaling.autoscaling_group_availability_zones
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.autoscaling.iam_role_arn
}

# ----------------------------------------------------
# security group outputs
# ----------------------------------------------------

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = module.security_group.security_group_arn
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.security_group.security_group_id
}
