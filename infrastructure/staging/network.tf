module "network" {
  source = "../modules/network"

  name        = local.name
  environment = local.environment

  cidr_block = "10.0.0.0/16"
  az_count   = 2
}
