# dlcsjobprocessor application
module "job_processor" {
  source = "../modules/ecs/private"

  name        = "job-processor"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.job_processor_url}:staging"

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/dds-connstr"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/staging/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/staging/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging"
  }

  healthcheck = {
    command     = ["CMD-SHELL", "curl -f http://localhost:80/management/healthcheck"]
    interval    = 30
    retries     = 5
    timeout     = 5
    startPeriod = 30
  }
}

resource "aws_iam_role_policy" "jobprocessor_readwrite_storagemaps_bucket" {
  name   = "jobprocessor-stage-readwrite-stage-storagemaps-bucket"
  role   = module.job_processor.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "jobprocessor_readwrite_presentation_bucket" {
  name   = "jobprocessor-stage-readwrite-stage-presentation-bucket"
  role   = module.job_processor.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

# dlcsjobprocessor, staging hosted pointing at Prod storage
module "job_processor_stageprod" {
  source = "../modules/ecs/private"

  name        = "job-processor"
  environment = local.environment_alt
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.job_processor_url}:staging-prod"

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentationstgprd-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsstgprd-connstr"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/staging/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/staging/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging-Prod"
  }

  healthcheck = {
    command     = ["CMD-SHELL", "curl -f http://localhost:80/management/healthcheck"]
    interval    = 30
    retries     = 5
    timeout     = 5
    startPeriod = 30
  }
}

resource "aws_iam_role_policy" "jobprocessorstgprd_readwrite_storagemaps_bucket" {
  name   = "jobprocessor-stageprd-readwrite-stage-storagemaps-bucket"
  role   = module.job_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}


resource "aws_iam_role_policy" "jobprocessorstgprd_readwrite_presentation_bucket" {
  name   = "jobprocessor-stageprd-readwrite-stage-presentation-bucket"
  role   = module.job_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}