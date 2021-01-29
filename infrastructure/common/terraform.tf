provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }

  region = var.region
}

terraform {
  required_version = ">= 0.14"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/common/terraform.tfstate"
    region = "eu-west-1"

    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.21.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}