module "network" {
  source = "../modules/network"

  name        = local.name
  environment = local.environment

  cidr_block = "10.0.0.0/16"
  az_count   = 2
}

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

