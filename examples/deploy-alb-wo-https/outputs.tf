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
