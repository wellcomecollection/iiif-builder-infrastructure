# dlcsjobprocessor application
module "job_processor" {
  source = "../modules/ecs/private"

  name        = "job-processor"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.job_processor_url}:staging-new"

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging-new/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging-new/dds-connstr"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
    Dlcs__ApiKey                          = "iiif-builder/staging-new/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/staging-new/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT" = "Staging-New"
  }

  healthcheck = {
    command     = ["CMD-SHELL", "curl -f http://localhost:80/management/healthcheck"]
    interval    = 30
    retries     = 5
    timeout     = 5
    startPeriod = 30
  }
}

module "job_processor_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.job_processor.service_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "jobprocessor_read_wellcomecollection_storage_staging_bucket" {
  name   = "jobprocessor-stage-new-read-wellcomecollection-storage-staging-bucket"
  role   = module.job_processor.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "jobprocessor_readwrite_storagemaps_bucket" {
  name   = "jobprocessor-stage-new-readwrite-stage-new-storagemaps-bucket"
  role   = module.job_processor.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "jobprocessor_readwrite_presentation_bucket" {
  name   = "jobprocessor-stage-new-readwrite-stage-new-presentation-bucket"
  role   = module.job_processor.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}
