# workflow processor
module "workflow_processor" {
  source = "../modules/ecs/private"

  name        = "workflow-processor"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.workflow_processor_url}:production"

  cpu    = 1024
  memory = 4096

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.production_security_group_id, ]

  secret_env_vars = {
    ConnectionStrings__DdsInstrumentation = "iiif-builder/production/ddsinstrumentation-connstr"
    ConnectionStrings__Dds                = "iiif-builder/production/dds-connstr"
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

  healthcheck = {
    command     = ["CMD-SHELL", "curl -f http://localhost:80/management/healthcheck"]
    interval    = 30
    retries     = 5
    timeout     = 5
    startPeriod = 30
  }
}

# wellcome-collection production storage bucket (in diff aws account)
resource "aws_iam_role_policy" "workflowprocessor_read_wellcomecollection_storage_bucket" {
  name   = "workflowprocessor-read-wellcomecollection-storage-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_bucket_read.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_storagemaps_bucket" {
  name   = "workflowprocessor-readwrite-storagemaps-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_presentation_bucket" {
  name   = "workflowprocessor-readwrite-presentation-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_text_bucket" {
  name   = "workflowprocessor-readwrite-text-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_anno_bucket" {
  name   = "workflowprocessor-readwrite-anno-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.annotations_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_publish_invalidate_topic" {
  name   = "workflowprocessor-publish-invalidate-sns-topic"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.invalidate_cache_publish.json
}