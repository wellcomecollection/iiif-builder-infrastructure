data "aws_subnet" "private_subnets" {
  for_each = toset(data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets)
  id       = each.value
}

resource "aws_ecs_cluster" "iiif_builder" {
  name = local.full_name
  tags = local.common_tags
}