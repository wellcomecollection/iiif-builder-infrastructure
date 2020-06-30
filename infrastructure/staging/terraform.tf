provider "aws" {
  version = "~> 2.46"
  region  = var.region
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/stage/terraform.tfstate"
    region = "eu-west-1"
  }
}