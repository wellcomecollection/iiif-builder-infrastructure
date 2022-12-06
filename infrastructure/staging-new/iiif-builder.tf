# IIIF-Builder app
module "iiif_builder" {
  source = "../modules/ecs/web"

  name        = "iiif-builder"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  # ?? what should this suffix be?
  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:staging"
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

  listener_priority = 210
  hostname          = "dds-stage-new"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging-new/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging-new/dds-connstr"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/staging-new/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/staging-new/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT"                  = "Staging-New"
    "FeatureManagement__TextServices"         = "False"
    "FeatureManagement__PresentationServices" = "True"
  }
}

module "iiif_builder_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.iiif_builder.service_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilder_read_wellcomecollection_storage_staging_bucket" {
  name   = "iiifbuilder-stage-new-read-wellcomecollection-storage-staging-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_readwrite_storagemaps_bucket" {
  name   = "iiifbuilder-stage-new-readwrite-stage-new-storagemaps-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilder_read_presentation_bucket" {
  name   = "iiifbuilder-stage-new-read-stage-new-presentation-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.presentation_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_read_anno_bucket" {
  name   = "iiifbuilder-stage-new-read-stage-new-anno-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.annotations_read.json
}

