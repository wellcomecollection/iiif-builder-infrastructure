provider "aws" {
  region = var.region

  profile = "wcdev"
}

terraform {
  required_version = ">= 1.8"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/common/terraform.tfstate"
    region = "eu-west-1"

    profile = "wcdev"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}
