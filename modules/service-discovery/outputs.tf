output "arn" {
  description = "The ARN that Amazon Route 53 assigns to the namespace when you create it."
  value       = aws_service_discovery_private_dns_namespace.namespace.arn
}