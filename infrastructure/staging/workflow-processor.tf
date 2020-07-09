module "workflow-processor" {
  source = "../modules/ecs/private"

  name        = "workflow-processor"
  environment = local.environment
  vpc_id      = local.vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.workflow_processor_url}:staging"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  secret_env_vars = {
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/dds-connstr"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}