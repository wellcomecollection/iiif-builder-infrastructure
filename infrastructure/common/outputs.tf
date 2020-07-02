output "iiif_builder_url" {
  value = aws_ecr_repository.iiif_builder.repository_url
}

output "staging_security_group_id" {
  value = aws_security_group.staging.id
}