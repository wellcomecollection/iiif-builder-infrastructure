variable "region" {
  default = "eu-west-1"
}

locals {
  domain = "wellcomecollection.digirati.io"

  common_tags = {
    Terraform = true
    Name      = "iiif-builder",
    Project   = "iiif-builder"
  }
}