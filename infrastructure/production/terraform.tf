provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }

  version = "~> 2.46"
  region  = var.region
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/production/terraform.tfstate"
    region = "eu-west-1"

    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }
}