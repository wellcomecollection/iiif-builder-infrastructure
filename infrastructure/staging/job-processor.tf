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
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
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

module "job_processor_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.job_processor.service_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "jobprocessor_read_wellcomecollection_storage_staging_bucket" {
  name   = "jobprocessor-stage-read-wellcomecollection-storage-staging-bucket"
  role   = module.job_processor.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
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
    Dlcs__ApiKey                          = "iiif-builder/stage-prd/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/stage-prd/dlcs-apisecret"
  }

  env_vars = {    
    "ASPNETCORE_ENVIRONMENT" = "Staging-Prod"
    "ASPNETCORE_URLS"        = "http://[::]:80"
    "ASPNETCORE_HTTP_PORTS"  = "80"
  }

  healthcheck = {
    command     = ["CMD-SHELL", "curl -f http://localhost:80/management/healthcheck"]
    interval    = 30
    retries     = 5
    timeout     = 5
    startPeriod = 30
  }
}

module "job_processor_stageprod_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.job_processor_stageprod.service_name
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "jobprocessorstgprd_read_wellcomecollection_storage_bucket" {
  name   = "jobprocessor-stageprd-read-wellcomecollection-storage-bucket"
  role   = module.job_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "jobprocessorstgprd_readwrite_storagemaps_test_bucket" {
  name   = "jobprocessor-stageprd-readwrite-test-storagemaps-bucket"
  role   = module.job_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_test_readwrite.json
}

resource "aws_iam_role_policy" "jobprocessorstgprd_readwrite_presentation_test_bucket" {
  name   = "jobprocessor-stageprd-readwrite-test-presentation-bucket"
  role   = module.job_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.presentation_test_readwrite.json
}
