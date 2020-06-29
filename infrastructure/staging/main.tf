data "aws_security_group" "default" {
  vpc_id = module.network.vpc_id
  name   = "default"
}

module "load_balancer" {
  source = "../modules/load_balancer"

  name        = local.name
  environment = local.environment

  public_subnets = module.network.public_subnets
  vpc_id         = module.network.vpc_id

  service_lb_security_group_ids = [
    data.aws_security_group.default.id,
  ]

  certificate_domain = "dlcs.io"

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

module "rds" {
  source = "../modules/rds"

  name              = local.name
  environment       = local.environment
  vpc_id            = module.network.vpc_id
  db_instance_class = "db.m4.large"
  db_storage        = 250
  db_subnets        = module.network.private_subnets
  db_ingress_cidrs  = module.network.private_cidrs

  db_security_group_ids = [
    data.aws_security_group.default.id,
  ]

  db_password_ssm_key = "/aws/reference/secretsmanager/staging/iiif-builder/db_password"
  db_username_ssm_key = "/aws/reference/secretsmanager/staging/iiif-builder/db_username"
}