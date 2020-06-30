locals {
  # Common tags to be assigned to all resources
  environment = "stage"
  name        = "iiif-builder"
  full_name   = "${local.name}-${local.environment}"

  common_tags = {
    "Environment" = local.environment
    "Terraform"   = true
    "Name"        = local.full_name
  }

  vpc_id = "vpc-0422549322a611c44"
  vpc_private_subnets = [
    "subnet-061cc8889c4af6419",
    "subnet-03a403bd266f8069a",
    "subnet-0b268a7a49008970a",
  ]
  vpc_public_subnets = [
    "subnet-0665cc7fa261ad8a4",
    "subnet-04ea48a807334030a",
    "subnet-0622d36b429f850f3",
  ]
  vpc_private_cidr = [
    "172.56.128.0/19",
    "172.56.160.0/19",
    "172.56.192.0/19",
  ]
}

variable "region" {
  default = "eu-west-1"
}