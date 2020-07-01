locals {

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
}

variable "region" {
  default = "eu-west-1"
}