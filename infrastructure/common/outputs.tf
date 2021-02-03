output "iiif_builder_url" {
  value = aws_ecr_repository.iiif_builder.repository_url
}

output "dashboard_url" {
  value = aws_ecr_repository.dashboard.repository_url
}

output "workflow_processor_url" {
  value = aws_ecr_repository.workflow_processor.repository_url
}

output "job_processor_url" {
  value = aws_ecr_repository.job_processor.repository_url
}

output "pdf_generator_url" {
  value = aws_ecr_repository.pdf_generator.repository_url
}

output "staging_security_group_id" {
  value = aws_security_group.staging.id
}

output "production_security_group_id" {
  value = aws_security_group.production.id
}

output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.iiif_builder.id
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.iiif_builder.arn
}

output "lb_listener_arn" {
  value = module.load_balancer.https_listener_arn
}

output "lb_zone_id" {
  value = module.load_balancer.lb_zone_id
}

output "lb_fqdn" {
  value = module.load_balancer.lb_dns_name
}

output "wellcomecollection_digirati_io_zone_id" {
  value = aws_route53_zone.wellcomecollection_digirati_io.zone_id
}

output "wellcomecollection_digirati_io" {
  value = aws_route53_zone.wellcomecollection_digirati_io.name
}