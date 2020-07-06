module "load_balancer" {
  source = "../modules/load_balancer"

  name        = local.name
  environment = local.environment

  public_subnets = local.vpc_public_subnets
  vpc_id         = local.vpc_id

  service_lb_security_group_ids = [
    data.terraform_remote_state.common.outputs.staging_security_group_id,
  ]

  certificate_domain = local.domain

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

module "rds" {
  source = "../modules/rds"

  name        = local.name
  environment = local.environment
  vpc_id      = local.vpc_id

  db_instance_class = "db.m4.large"
  db_storage        = 250
  db_subnets        = local.vpc_private_subnets
  db_ingress_cidrs  = local.vpc_private_cidr

  db_security_group_ids = [
    data.terraform_remote_state.common.outputs.staging_security_group_id,
  ]

  db_creds_secret_key = "iiif-builder/staging/db_admin"
}

data "aws_route53_zone" "external" {
  name = local.domain
}

resource "aws_ecs_cluster" "iiif_builder" {
  name = local.full_name
  tags = local.common_tags
}

# main IIIF-Builder application
module "iiif-builder" {
  source = "../modules/ecs"

  name        = local.name
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

  lb_listener_arn = module.load_balancer.https_listener_arn
  lb_zone_id      = module.load_balancer.lb_zone_id
  lb_fqdn         = module.load_balancer.lb_dns_name
  #path_patterns     = ["/iiif/*"]
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
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/dds-connstr"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}

# dds-dashboard application
module "dashboard" {
  source = "../modules/ecs"

  name        = "iiif-builder-dashboard"
  environment = local.environment
  vpc_id      = local.vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.dashboard_url}:staging"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = module.load_balancer.https_listener_arn
  lb_zone_id      = module.load_balancer.lb_zone_id
  lb_fqdn         = module.load_balancer.lb_dns_name

  listener_priority = 20
  hostname          = "dds-stage"
  domain            = local.domain
  zone_id           = data.aws_route53_zone.external.id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/dds-connstr"
    AzureAd__TenantId                     = "iiif-builder/staging/azuread-tenantid"
    AzureAd__ClientId                     = "iiif-builder/staging/azuread-clientid"
    Storage-Production__ClientId          = "iiif-builder/common/storage/clientid"
    Storage-Production__ClientSecret      = "iiif-builder/common/storage/clientsecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}

data "aws_iam_role" "dashboard_task_role" {
  name = module.dashboard.task_role_name
}