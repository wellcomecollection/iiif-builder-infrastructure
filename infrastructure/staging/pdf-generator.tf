# pdf-generator application
module "pdf_generator" {
  source = "../modules/ecs/web"

  name        = "pdf-generator"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${data.terraform_remote_state.common.outputs.pdf_generator_url}:staging"
  container_port = 8000

  cpu    = 256
  memory = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  service_discovery_namespace_id = data.terraform_remote_state.common.outputs.service_discovery_namespace_id
  service_subnets                = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids     = [data.terraform_remote_state.common.outputs.production_security_group_id, ]

  healthcheck_path = "/pdf-cover/ping"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 6
  hostname          = "pdf-stage"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 8000
    hostPort      = 8000
    protocol      = "tcp"
  }]

  env_vars = {
    "MANIFEST_BUCKET" = aws_s3_bucket.presentation_stage.id
    "KEY_PREFIX"      = "v3"
  }
}

resource "aws_iam_role_policy" "pdf_generator_read_presentation_stage_bucket" {
  name   = "pdf-generator-stage-read-stage-presentation-bucket"
  role   = module.pdf_generator.task_role_name
  policy = data.aws_iam_policy_document.presentation_stage_read.json
}
