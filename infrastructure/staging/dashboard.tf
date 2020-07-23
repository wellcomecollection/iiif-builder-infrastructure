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

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

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
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/dds-connstr"
    AzureAd__TenantId                     = "iiif-builder/staging/azuread-tenantid"
    AzureAd__ClientId                     = "iiif-builder/staging/azuread-clientid"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
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

# wellcome-collection staging bucket (in diff aws account)
resource "aws_iam_role_policy" "dashboard_read_wellcomecollection_storage_staging_bucket" {
  name   = "dashboard-stage-read-wellcomecollection-storage-staging-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_storagemaps_bucket" {
  name   = "dashboard-stage-readwrite-stage-storagemaps-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_presentation_bucket" {
  name   = "dashboard-stage-readwrite-stage-presentation-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_text_bucket" {
  name   = "dashboard-stage-readwrite-stage-text-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}

# dashboard, staging hosted pointing at Prod storage
module "dashboard_stageprod" {
  source = "../modules/ecs/web"

  name        = "iiif-builder-dashboard"
  environment = local.environment_alt
  vpc_id      = local.vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.dashboard_url}:staging-prod"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 60
  hostname          = "dds-stageprd"
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
    AzureAd__TenantId                     = "iiif-builder/staging/azuread-tenantid"
    AzureAd__ClientId                     = "iiif-builder/staging/azuread-clientid"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/staging/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/staging/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging-Prod"
  }
}

data "aws_iam_role" "dashboardstgprd_task_role" {
  name = module.dashboard_stageprod.task_role_name
}

# wellcome-collection bucket (in diff aws account)
resource "aws_iam_role_policy" "dashboardstgprd_read_wellcomecollection_storage_bucket" {
  name   = "dashboard-stageprd-read-wellcomecollection-storage-staging-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

# storage maps
resource "aws_iam_role_policy" "dashboardstgprd_readwrite_storagemaps_bucket" {
  name   = "dashboard-stageprd-readwrite-stage-storagemaps-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "dashboardstgprd_readwrite_presentation_bucket" {
  name   = "dashboard-stageprd-readwrite-stage-presentation-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "dashboardstgprd_readwrite_text_bucket" {
  name   = "dashboard-stageprd-readwrite-stage-text-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}