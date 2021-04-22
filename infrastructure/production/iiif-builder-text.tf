# IIIF-Builder app for /search and /text
module "iiif_builder_text" {
  source = "../modules/ecs/web"

  name        = "iiif-builder-text"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:production"
  container_port = 80

  cpu    = 1024
  memory = 4096

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.production_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn

  listener_priority = 40
  path_patterns     = ["/text*", "/search*"]
  hostname          = "dds"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  create_dns        = false

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/production/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/production/dds-connstr"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT"                  = "Production"
    "FeatureManagement__TextServices"         = "True"
    "FeatureManagement__PresentationServices" = "False"
  }
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilder_text_read_wellcomecollection_storage_bucket" {
  name   = "iiifbuilder-text-read-wellcomecollection-storage-bucket"
  role   = module.iiif_builder_text.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_text_readwrite_storagemaps_bucket" {
  name   = "iiifbuilder-text-readwrite-storagemaps-bucket"
  role   = module.iiif_builder_text.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilder_text_read_text_bucket" {
  name   = "iiifbuilder-text-read-text-bucket"
  role   = module.iiif_builder_text.task_role_name
  policy = data.aws_iam_policy_document.text_read.json
}