output "alb_arn" {
  description = "The ARN of the ALB."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = module.alb.alb_dns_name
}

output "alb_hosted_zone_id" {
  description = "The ID of the hosted zone where the ALB DNS record was created."
  value       = module.alb.alb_hosted_zone_id
}

output "alb_name" {
  description = "The name of the ALB."
  value       = module.alb.alb_name
}

output "alb_dns_record_name" {
  description = "The name of the ALB DNS record."
  value       = module.alb.alb_dns_record_name
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = module.alb.alb_security_group_id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = module.alb.http_listener_arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener."
  value       = module.alb.https_listener_arn
}
