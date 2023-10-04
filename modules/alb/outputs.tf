output "alb_arn" {
  description = "The ARN of the ALB."
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_lb.alb.dns_name
}

output "alb_hosted_zone_id" {
  description = "The ID of the hosted zone where the ALB DNS record was created."
  value       = aws_lb.alb.zone_id
}

output "alb_name" {
  description = "The name of the ALB."
  value       = aws_lb.alb.name
}

output "alb_dns_record_name" {
  description = "The name of the ALB DNS record."
  value       = try(aws_route53_record.alb[0].name, null)
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = try(aws_lb_listener.http[0].arn, aws_lb_listener.redirect[0].arn)
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener."
  value       = try(aws_lb_listener.https[0].arn, null)
}
