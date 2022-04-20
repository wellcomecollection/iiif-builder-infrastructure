resource "aws_ecr_repository" "auth" {
  name = "iiif-builder-auth"
  tags = {
    Terraform = true
    Project   = "iiif-builder"
  }
}

# Auth Test app
module "auth_test" {
  source = "../modules/ecs/web"

  name        = "auth-test"
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  docker_image   = "${aws_ecr_repository.auth.repository_url}:test"
  container_port = 80

  cpu    = 256
  memory = 512

  ecs_cluster_arn            = aws_ecs_cluster.iiif_builder.arn
  service_subnets            = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  service_security_group_ids = [data.terraform_remote_state.common.outputs.staging_security_group_id, ]

  healthcheck_path = "/mappings"

  lb_listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  lb_zone_id      = data.terraform_remote_state.common.outputs.lb_zone_id
  lb_fqdn         = data.terraform_remote_state.common.outputs.lb_fqdn

  listener_priority = 60
  hostname          = "auth-test"
  domain            = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io
  zone_id           = data.terraform_remote_state.common.outputs.wellcomecollection_digirati_io_zone_id

  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]

  secret_env_vars = {
    Auth0__Domain       = "iiif-builder/staging/auth0-domain"
    Auth0__ClientId     = "iiif-builder/staging/auth0-clientid"
    Auth0__ClientSecret = "iiif-builder/staging/auth0-clientsecret"
  }
}

module "auth_test_scaling" {
  source = "../modules/autoscaling/scheduled"

  cluster_name = aws_ecs_cluster.iiif_builder.name
  service_name = module.auth_test.service_name
}