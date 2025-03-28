# IIIF-Builder-text app
module "iiif_builder_text" {
  source = "../modules/ecs/web"

  name        = "iiif-builder-text"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:staging"
  container_port = 80

  cpu    = 512
  memory = 2048

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn

  listener_priority = 30
  path_patterns     = ["/text*", "/search*"]
  hostname          = "dds-stage"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  create_dns        = false

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
    "ASPNETCORE_ENVIRONMENT"                  = "Staging"
    "ASPNETCORE_URLS"                         = "http://*:80"
    "ASPNETCORE_HTTP_PORTS"                   = "80"
    "FeatureManagement__TextServices"         = "True"
    "FeatureManagement__PresentationServices" = "False"
  }
}

module "iiif_builder_text_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.iiif_builder_text.service_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilder_text_read_wellcomecollection_storage_staging_bucket" {
  name   = "iiifbuilder-text-stage-read-wellcomecollection-storage-staging-bucket"
  role   = module.iiif_builder_text.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "iiifbuilder_text_readwrite_storagemaps_bucket" {
  name   = "iiifbuilder-text-stage-readwrite-stage-storagemaps-bucket"
  role   = module.iiif_builder_text.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilder_text_read_text_bucket" {
  name   = "iiifbuilder-text-stage-read-stage-text-bucket"
  role   = module.iiif_builder_text.task_role_name
  policy = data.aws_iam_policy_document.text_read.json
}

# IIIF-Builder, staging hosted pointing at Prod storage
module "iiif_builder_text_stageprod" {
  source = "../modules/ecs/web"

  name        = "iiif-builder-text"
  environment = local.environment_alt
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.iiif_builder_url}:staging-prod"
  container_port = 80

  cpu    = 512
  memory = 1024

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/management/healthcheck"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn

  listener_priority = 34
  path_patterns     = ["/text*", "/search*"]
  hostname          = "dds-test"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  create_dns        = false

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
    Dlcs__ApiKey                          = "iiif-builder/stage-prd/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/stage-prd/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT"                  = "Staging-Prod"
    "ASPNETCORE_URLS"                         = "http://*:80"
    "ASPNETCORE_HTTP_PORTS"                   = "80"
    "FeatureManagement__TextServices"         = "True"
    "FeatureManagement__PresentationServices" = "False"
  }
}

module "iiif_builder_text_stageprod_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.iiif_builder_text_stageprod.service_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "iiifbuilderstgprd_text_read_wellcomecollection_storage_staging_bucket" {
  name   = "iiifbuilder-text-stageprd-read-wellcomecollection-storage-staging-bucket"
  role   = module.iiif_builder_text_stageprod.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "iiifbuilderstgprd_text_readwrite_storagemaps_test_bucket" {
  name   = "iiifbuilder-text-stageprd-readwrite-test-storagemaps-bucket"
  role   = module.iiif_builder_text_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_test_readwrite.json
}

resource "aws_iam_role_policy" "iiifbuilderstgprd_text_read_text_test_bucket" {
  name   = "iiifbuilder-text-stageprd-read-test-text-bucket"
  role   = module.iiif_builder_text_stageprod.task_role_name
  policy = data.aws_iam_policy_document.text_test_read.json
}
