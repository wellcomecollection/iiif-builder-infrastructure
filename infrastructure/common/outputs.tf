output "iiif_builder_url" {
  value = aws_ecr_repository.iiif_builder.repository_url
}

output "staging_security_group_id" {
  value = aws_security_group.staging.id
}

output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.iiif_builder.id
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.iiif_builder.arn
}