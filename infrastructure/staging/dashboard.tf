# dds-dashboard application
module "dashboard" {
  source = "../modules/ecs/web"

  name        = "iiif-builder-dashboard"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.dashboard_url}:staging"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 8
  hostname          = "dash-stage"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/dds-connstr"
    AzureAd__TenantId                     = "iiif-builder/common/azuread-tenantid"
    AzureAd__ClientId                     = "iiif-builder/common/azuread-clientid"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}

module "dashboard_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.dashboard.service_name
}

# wellcome-collection staging storage bucket (in diff aws account)
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

resource "aws_iam_role_policy" "dashboard_read_presentation_bucket" {
  name   = "dashboard-stage-read-stage-presentation-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.presentation_read.json
}

resource "aws_iam_role_policy" "dashboard_read_text_bucket" {
  name   = "dashboard-stage-read-stage-text-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.text_read.json
}

resource "aws_iam_role_policy" "dashboard_read_anno_bucket" {
  name   = "dashboard-stageprd-read-stage-anno-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.annotations_read.json
}

# dashboard, staging hosted pointing at Prod storage
module "dashboard_stageprod" {
  source = "../modules/ecs/web"

  name        = "iiif-builder-dashboard"
  environment = local.environment_alt
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.dashboard_url}:staging-prod"
  container_port = 80

  cpu    = 512
  memory = 2048

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 10
  hostname          = "dash-test"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentationstgprd-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsstgprd-connstr"
    AzureAd__TenantId                     = "iiif-builder/common/azuread-tenantid"
    AzureAd__ClientId                     = "iiif-builder/common/azuread-clientid"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging-Prod"
  }
}

module "dashboard_stageprod_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.dashboard_stageprod.service_name
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "dashboardstgprd_read_wellcomecollection_storage_bucket" {
  name   = "dashboard-stageprd-read-wellcomecollection-storage-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "dashboardstgprd_readwrite_storagemaps_bucket" {
  name   = "dashboard-stageprd-readwrite-stage-storagemaps-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "dashboardstgprd_read_presentation_bucket" {
  name   = "dashboard-stageprd-read-stage-presentation-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.presentation_read.json
}

resource "aws_iam_role_policy" "dashboardstgprd_read_text_bucket" {
  name   = "dashboard-stageprd-read-stage-text-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.text_read.json
}

resource "aws_iam_role_policy" "dashboardstgprd_read_anno_bucket" {
  name   = "dashboard-stageprd-read-stage-anno-bucket"
  role   = module.dashboard_stageprod.task_role_name
  policy = data.aws_iam_policy_document.annotations_read.json
}