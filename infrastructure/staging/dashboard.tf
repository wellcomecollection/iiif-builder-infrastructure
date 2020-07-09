# dds-dashboard application
module "dashboard" {
  source = "../modules/ecs/web"

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
    Dlcs__ApiKey                          = "iiif-builder/staging/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/staging/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}

data "aws_iam_role" "dashboard_task_role" {
  name = module.dashboard.task_role_name
}

resource "aws_iam_role_policy" "dashboard_read_wellcomecollection_storage_bucket" {
  name   = "${local.full_name}-read-wellcomecollection-storage-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "dashboard_read_wellcomecollection_storage_staging_bucket" {
  name   = "${local.full_name}-read-wellcomecollection-storage-staging-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_storagemaps_bucket" {
  name   = "${local.full_name}-readwrite-wellcomecollection-stage-iiif-storagemaps-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_presentation_bucket" {
  name   = "${local.full_name}-readwrite-wellcomecollection-stage-iiif-presentation-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_text_bucket" {
  name   = "${local.full_name}-readwrite-wellcomecollection-stage-iiif-text-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}