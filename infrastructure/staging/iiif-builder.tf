# IIIF-Builder app
module "iiif_builder" {
  source = "../modules/ecs/web"

  name        = "iiif-builder"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

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

  listener_priority = 7
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
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }
}

module "iiif_builder_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.iiif_builder.service_name
}

data "aws_iam_role" "iiifbuilder_task_role" {
  name = module.iiif_builder.task_role_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilder_read_wellcomecollection_storage_staging_bucket" {
  name   = "iiifbuilder-stage-read-wellcomecollection-storage-staging-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_readwrite_storagemaps_bucket" {
  name   = "iiifbuilder-stage-readwrite-stage-storagemaps-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilder_readwrite_presentation_bucket" {
  name   = "iiifbuilder-stage-readwrite-stage-presentation-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilder_readwrite_text_bucket" {
  name   = "iiifbuilder-stage-readwrite-stage-text-bucket"
  role   = module.iiif_builder.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}


# IIIF-Builder, staging hosted pointing at Prod storage
module "iiif_builder_stageprod" {
  source = "../modules/ecs/web"

  name        = "iiif-builder"
  environment = local.environment_alt
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:staging-prod"
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

  listener_priority = 9
  hostname          = "iiif-test"
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
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging-Prod"
  }
}

module "iiif_builder_stageprod_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.iiif_builder_stageprod.service_name
}

data "aws_iam_role" "iiifbuilderstgprd_task_role" {
  name = module.iiif_builder_stageprod.task_role_name
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilderstgprd_read_wellcomecollection_storage_bucket" {
  name   = "iiifbuilder-stageprd-read-wellcomecollection-storage-bucket"
  role   = module.iiif_builder_stageprod.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

# storage maps
resource "aws_iam_role_policy" "iiifbuilderstgprd_readwrite_storagemaps_bucket" {
  name   = "iiifbuilder-stageprd-readwrite-stage-storagemaps-bucket"
  role   = module.iiif_builder_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilderstgprd_readwrite_presentation_bucket" {
  name   = "iiifbuilder-stageprd-readwrite-stage-presentation-bucket"
  role   = module.iiif_builder_stageprod.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilderstgprd_readwrite_text_bucket" {
  name   = "iiifbuilder-stageprd-readwrite-stage-text-bucket"
  role   = module.iiif_builder_stageprod.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}