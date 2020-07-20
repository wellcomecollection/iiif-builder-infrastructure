# IIIF-Builder app
module "iiif_builder" {
  source = "../modules/ecs/web"

  name        = "iiif-builder"
  environment = local.environment
  vpc_id      = local.vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:staging"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn   = module.load_balancer.https_listener_arn
  lb_zone_id        = module.load_balancer.lb_zone_id
  lb_fqdn           = module.load_balancer.lb_dns_name
  listener_priority = 10
  hostname          = "iiif-stage"
  domain            = local.domain
  zone_id           = data.aws_route53_zone.external.id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/dds-connstr"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}

# IIIF-Builder, staging hosted pointing at Prod storage
module "iiif_builder_stageprod" {
  source = "../modules/ecs/web"

  name        = "iiif-builder"
  environment = local.environment_alt
  vpc_id      = local.vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:staging-prod"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn   = module.load_balancer.https_listener_arn
  lb_zone_id        = module.load_balancer.lb_zone_id
  lb_fqdn           = module.load_balancer.lb_dns_name
  listener_priority = 50
  hostname          = "iiif-stageprd"
  domain            = local.domain
  zone_id           = data.aws_route53_zone.external.id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentationstgprd-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsstgprd-connstr"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging-Prod"
  }
}