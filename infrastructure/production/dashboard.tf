# dds-dashboard application
module "dashboard" {
  source = "../modules/ecs/web"

  name        = "dashboard"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.dashboard_url}:production"
  container_port = 80

  cpu    = 512
  memory = 2048

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.production_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 24
  hostname          = "dash"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/production/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/production/dds-connstr"
    AzureAd__TenantId                     = "iiif-builder/common/azuread-tenantid"
    AzureAd__ClientId                     = "iiif-builder/common/azuread-clientid"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT"                    = "Production"
    "CacheInvalidation__InvalidateIIIFTopicArn" = data.aws_sns_topic.iiif_invalidate_cache.arn
    "CacheInvalidation__InvalidateApiTopicArn"  = data.aws_sns_topic.api_invalidate_cache.arn
  }
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "dashboard_read_wellcomecollection_storage_bucket" {
  name   = "dashboard-read-wellcomecollection-storage-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "dashboard_readwrite_storagemaps_bucket" {
  name   = "dashboard-readwrite-storagemaps-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "dashboard_read_presentation_bucket" {
  name   = "dashboard-read-presentation-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.presentation_read.json
}

resource "aws_iam_role_policy" "dashboard_read_text_bucket" {
  name   = "dashboard-read-text-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.text_read.json
}

resource "aws_iam_role_policy" "dashboard_read_anno_bucket" {
  name   = "dashboard-read-anno-bucket"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.annotations_read.json
}

resource "aws_iam_role_policy" "dashboard_publish_invalidate_topic" {
  name   = "dashboard-publish-invalidate-sns-topic"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.invalidate_cache_publish.json
}

resource "aws_iam_role_policy" "dashboard_write_to_born_digital_notifications_queue" {
  name   = "dashboard-write-to-born-digital-notifications-queue"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.born_digital_notifications_write_to_queue.json
}

resource "aws_iam_role_policy" "dashboard_write_to_digitised_notifications_queue" {
  name   = "dashboard-write-to-digitised-notifications-queue"
  role   = module.dashboard.task_role_name
  policy = data.aws_iam_policy_document.digitised_notifications_write_to_queue.json
}	
