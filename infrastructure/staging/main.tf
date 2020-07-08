module "load_balancer" {
  source = "../modules/load_balancer"

  name        = local.name
  environment = local.environment

  public_subnets = local.vpc_public_subnets
  vpc_id         = local.vpc_id

  service_lb_security_group_ids = [
    data.terraform_remote_state.common.outputs.staging_security_group_id,
  ]

  certificate_domain = local.domain

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

module "rds" {
  source = "../modules/rds"

  name        = local.name
  environment = local.environment
  vpc_id      = local.vpc_id

  db_instance_class = "db.m4.large"
  db_storage        = 250
  db_subnets        = local.vpc_private_subnets
  db_ingress_cidrs  = local.vpc_private_cidr

  db_security_group_ids = [
    data.terraform_remote_state.common.outputs.staging_security_group_id,
  ]

  db_creds_secret_key = "iiif-builder/staging/db_admin"
}

data "aws_route53_zone" "external" {
  name = local.domain
}

resource "aws_ecs_cluster" "iiif_builder" {
  name = local.full_name
  tags = local.common_tags
}