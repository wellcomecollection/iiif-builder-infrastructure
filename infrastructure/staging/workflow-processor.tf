# workflow processor
module "workflow_processor" {
  source = "../modules/ecs/private"

  name        = "workflow-processor"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.workflow_processor_url}:staging"

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

module "workflow_processor_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.workflow_processor.service_name
}

data "aws_iam_role" "workflowprocessor_task_role" {
  name = module.workflow_processor.task_role_name
}

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "workflowprocessor_read_wellcomecollection_storage_staging_bucket" {
  name   = "workflowprocessor-stage-read-wellcomecollection-storage-staging-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_storagemaps_bucket" {
  name   = "workflowprocessor-stage-readwrite-stage-storagemaps-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_presentation_bucket" {
  name   = "workflowprocessor-stage-readwrite-stage-presentation-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_text_bucket" {
  name   = "workflowprocessor-stage-readwrite-stage-text-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}

# workflow processor, staging pointing at prod storage
module "workflow_processor_stageprod" {
  source = "../modules/ecs/private"

  name        = "workflow-processor"
  environment = local.environment_alt
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.workflow_processor_url}:staging-prod"

  cpu    = 512
  memory = 2048

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/staging/ddsinstrumentationstgprd-connstr"
    ConnectionStrings__Dds                = "iiif-builder/staging/ddsstgprd-connstr"
    Storage__ClientId                     = "iiif-builder/common/storage/clientid"
    Storage__ClientSecret                 = "iiif-builder/common/storage/clientsecret"
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

module "workflow_processor_stageprod_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.workflow_processor_stageprod.service_name
}

data "aws_iam_role" "workflowprocessorstgprd_task_role" {
  name = module.workflow_processor_stageprod.task_role_name
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "workflowprocessorstgprd_read_wellcomecollection_storage_bucket" {
  name   = "workflowprocessor-stageprd-read-wellcomecollection-storage-bucket"
  role   = module.workflow_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "workflowprocessorstgprd_readwrite_storagemaps_bucket" {
  name   = "workflowprocessor-stageprd-readwrite-stage-storagemaps-bucket"
  role   = module.workflow_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessorstgprd_readwrite_presentation_bucket" {
  name   = "workflowprocessor-stageprd-readwrite-stage-presentation-bucket"
  role   = module.workflow_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessorstgprd_readwrite_text_bucket" {
  name   = "workflowprocessor-stageprd-readwrite-stage-text-bucket"
  role   = module.workflow_processor_stageprod.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}