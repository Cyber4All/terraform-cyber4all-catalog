# ----------------------------------------------------
# external security group outputs
# ----------------------------------------------------

output "external_security_group_arn" {
  description = "The ARN of the external alb security group"
  value       = module.external-sg.security_group_arn
}

output "external_security_group_id" {
  description = "The ID of the external alb security group"
  value       = module.external-sg.security_group_id
}

# ----------------------------------------------------
# internal security group outputs
# ----------------------------------------------------
output "internal_security_group_arn" { 
  description = "The ARN of the internal alb security group"
  value       = module.internal-sg.security_group_arn
}

output "internal_security_group_id" {
  description = "The ID of the internal alb security group"
  value       = module.internal-sg.security_group_id
}

# ----------------------------------------------------
# external applicaiton load balancer outputs
# ----------------------------------------------------

output "external_lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.external-alb.lb_id
}

output "external_lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.external-alb.lb_arn
}

output "external_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.external-alb.lb_dns_name
}

output "external_target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.external-alb.target_group_arns
}

output "external_target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.external-alb.target_group_arn_suffixes
}

output "external_target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.external-alb.target_group_names
}

# ----------------------------------------------------
# internal applicaiton load balancer outputs
# ----------------------------------------------------
output "internal_lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.internal-alb.lb_id
}

output "internal_lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.internal-alb.lb_arn
}

output "internal_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.internal-alb.lb_dns_name
}

output "internal_target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.internal-alb.target_group_arns
}

output "internal_target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.internal-alb.target_group_arn_suffixes
}

output "internal_target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.internal-alb.target_group_names
}
