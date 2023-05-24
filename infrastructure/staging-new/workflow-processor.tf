# workflow processor
module "workflow_processor" {
  source = "../modules/ecs/private"

  name        = "workflow-processor"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image = "${data.terraform_remote_state.common.outputs.workflow_processor_url}:staging-new"

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
    Dlcs__ApiKey                          = "iiif-builder/common/dlcs-apikey"
    Dlcs__ApiSecret                       = "iiif-builder/common/dlcs-apisecret"
  }

  env_vars = {
    "ASPNETCORE_ENVIRONMENT"                    = "Staging-New"
    "CacheInvalidation__InvalidateIIIFTopicArn" = data.aws_sns_topic.iiif_stage_new_invalidate_cache.arn
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

# wellcome-collection staging storage bucket (in diff aws account)
resource "aws_iam_role_policy" "workflowprocessor_read_wellcomecollection_storage_staging_bucket" {
  name   = "workflowprocessor-stage-new-read-wellcomecollection-storage-staging-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.wellcomecollection_storage_staging_bucket_read.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_storagemaps_bucket" {
  name   = "workflowprocessor-stage-new-readwrite-stage-new-storagemaps-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.storagemaps_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_presentation_bucket" {
  name   = "workflowprocessor-stage-new-readwrite-stage-new-presentation-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.presentation_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_text_bucket" {
  name   = "workflowprocessor-stage-new-readwrite-stage-new-text-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.text_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_readwrite_anno_bucket" {
  name   = "workflowprocessor-stage-new-readwrite-stage-new-anno-bucket"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.annotations_readwrite.json
}

resource "aws_iam_role_policy" "workflowprocessor_publish_invalidate_iiif_topic" {
  name   = "workflowprocessor-stage-new-publish-invalidate-iiif-sns-topic"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.iiif_stage_new_invalidate_cache_publish.json
}

resource "aws_iam_role_policy" "workflowprocessor_read_from_born_digital_notifications_staging_new_queue" {
  name   = "workflowprocessor-read-from-born-digital-notifications-staging-new-queue"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.born_digital_notifications_staging_new_read_from_queue.json
}

resource "aws_iam_role_policy" "workflowprocessor_read_from_digitised_notifications_staging_new_queue" {
  name   = "workflowprocessor-read-from-digitised-notifications-staging-new-queue"
  role   = module.workflow_processor.task_role_name
  policy = data.aws_iam_policy_document.digitised_notifications_staging_new_read_from_queue.json
}