data "aws_security_group" "default" {
  vpc_id = local.vpc_id
  name   = "default"
}

module "load_balancer" {
  source = "../modules/load_balancer"

  name        = local.name
  environment = local.environment

  public_subnets = local.vpc_public_subnets
  vpc_id         = local.vpc_id

  service_lb_security_group_ids = [
    data.aws_security_group.default.id,
  ]

  certificate_domain = "dlcs.io"

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

# module "rds" {
#   source = "../modules/rds"

#   name        = local.name
#   environment = local.environment
#   vpc_id      = local.vpc_id

#   db_instance_class = "db.m4.large"
#   db_storage        = 250
#   db_subnets        = local.vpc_private_subnets
#   db_ingress_cidrs  = local.vpc_private_cidr

#   db_security_group_ids = [
#     data.aws_security_group.default.id,
#   ]

#   db_password_ssm_key = "/aws/reference/secretsmanager/staging/iiif-builder/db_password"
#   db_username_ssm_key = "/aws/reference/secretsmanager/staging/iiif-builder/db_username"
# }

data "aws_route53_zone" "external" {
  name = "dlcs.io"
}

module "iiif-builder" {
  source = "../modules/ecs"

  name        = local.name
  environment = local.environment
  vpc_id      = local.vpc_id

  docker_image   = "crccheck/hello-world" #"${var.data.terraform_remote_state.common.outputs.iiif_builder_url}:staging"
  container_port = 8000

  cpu      = 256
  memory   = 512

  ecs_cluster_arn                = aws_ecs_cluster.iiif_builder.arn
  #service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
  service_subnets                = local.vpc_private_subnets
  service_security_group_ids     = [data.aws_security_group.default.id] # correct?

  healthcheck_path = "/" # confirm

  lb_listener_arn = module.load_balancer.https_listener_arn
  lb_zone_id      = module.load_balancer.lb_zone_id
  lb_fqdn         = module.load_balancer.lb_dns_name
  #path_patterns     = ["/iiif/*"]
  listener_priority = 10
  hostname          = "stage-iiif"
  domain            = "dlcs.io"
  zone_id           = data.aws_route53_zone.external.id
}

resource "aws_ecs_cluster" "iiif_builder" {
  name = local.full_name
  tags = local.common_tags
}

# resource "aws_service_discovery_private_dns_namespace" "namespace" {
#   name = local.full_name
#   vpc  = local.vpc_id
# }