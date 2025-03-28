data "aws_subnet" "private_subnets" {
  for_each = toset(data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets)
  id       = each.value
}

# NOTE: Connstr is _not_ updated automatically to keep out of state. Need to update appropriate secret
module "rds" {
  source = "../modules/rds"

  name        = local.name
  environment = local.environment
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  identifier_postfix = "-1"

  db_engine_version = "13.18"
  db_instance_class = "db.m6g.large"
  db_storage        = 250
  db_subnets        = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets
  db_ingress_cidrs  = [for s in data.aws_subnet.private_subnets : s.cidr_block]
  db_cert_authority = "rds-ca-rsa2048-g1"

  db_security_group_ids = [
    data.terraform_remote_state.common.outputs.production_security_group_id,
  ]

  db_creds_secret_key = "iiif-builder/production/db_admin"
}

resource "aws_ecs_cluster" "iiif_builder" {
  name = local.full_name
  tags = local.common_tags
}