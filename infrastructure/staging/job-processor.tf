module "job-processor" {
  source = "../modules/ecs/private"

  name        = "job-processor"
  environment = local.environment
  vpc_id      = local.vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.job_processor_url}:staging"

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  secret_env_vars = {
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/dds-connstr"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }

  healthcheck = {
    command     = ["CMD-SHELL", "curl -f http://localhost:80/management/healthcheck"]
    interval    = 30
    retries     = 5
    timeout     = 5
    startPeriod = 30
  }
}