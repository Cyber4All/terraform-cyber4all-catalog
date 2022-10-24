output "arn" {
  description = "The ARN that Amazon Route 53 assigns to the namespace when you create it."
  value       = aws_service_discovery_private_dns_namespace.namespace.arn
}

output "id" {
  description = "The ID of a namespace."
  value = aws_service_discovery_private_dns_namespace.namespace.id
}