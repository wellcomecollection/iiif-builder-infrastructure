# Common

Contains any infrastructure that is common to both the Staging and Production environments of iiif-builder.

## Services

- Security Groups - these are not shared across environments but some shared resources require them. Added here to avoid circular dependency between 'Common' and environment specific states.
- Load Balancer - both Staging and Production share LB.
- Container Registeries - ECR per application.
- Bastion Server - t2.micro, IP restricted access.
- Private Service Discovery namespace
- Route53 hosted zone for `wellcomecollection.digirati.io`

## Outputs

| Name                                   | Description                                   |
|----------------------------------------|-----------------------------------------------|
| iiif_builder_url                       | URL for iiif-builder ECR repo                 |
| dashboard_url                          | URL for dashboard ECR repo                    |
| workflow_processor_url                 | URL for workflow-processor ECR repo           |
| job_processor_url                      | URL for job-processor ECR repo                |
| pdf_generator_url                      | URL for pdf-generator ECR repo                |
| staging_security_group_id              | id of 'staging' security group                |
| production_security_group_id           | id of 'production' security group             |
| service_discovery_namespace_id         | id of service discovery namespace             |
| service_discovery_namespace_arn        | arn of service discovery namespace            |
| lb_listener_arn                        | arn of https listener                         |
| lb_zone_id                             | canonical hosted zone ID of the load balancer |
| lb_fqdn                                | fqdn for loat balancer                        |
| wellcomecollection_digirati_io         | DNS name for hosted zone                      |
| wellcomecollection_digirati_io_zone_id | ZoneId for hosted zone                        |