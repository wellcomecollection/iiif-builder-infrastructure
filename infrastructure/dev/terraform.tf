provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }

  region = var.region

  profile = "wcdev"
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/dev/terraform.tfstate"
    region = "eu-west-1"

    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"

    profile = "wcdev"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8"
    }
  }
}