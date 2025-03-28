# IIIF-Builder app
module "iiif_builder" {
  source = "../modules/ecs/web"

  name        = "iiif-builder"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:production"
  container_port = 80

  cpu    = 512
  memory = 4096

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.production_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 260
  hostname          = "dds"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/production/ddsinstrumentation-connstr-new"
    ConnectionStrings__Dds                = "iiif-builder/production/dds-connstr-new"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT"                  = "Production"
    "ASPNETCORE_URLS"                         = "http://*:80"
    "ASPNETCORE_HTTP_PORTS"                   = "80"
    "FeatureManagement__TextServices"         = "False"
    "FeatureManagement__PresentationServices" = "True"
  }
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilder_read_wellcomecollection_storage_bucket" {
  name   = "iiifbuilder-read-wellcomecollection-storage-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_readwrite_storagemaps_bucket" {
  name   = "iiifbuilder-readwrite-storagemaps-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilder_read_presentation_bucket" {
  name   = "iiifbuilder-read-presentation-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.presentation_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_read_anno_bucket" {
  name   = "iiifbuilder-read-anno-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.annotations_read.json
}