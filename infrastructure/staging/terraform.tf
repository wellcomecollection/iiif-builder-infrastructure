provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }

  region = var.region

  profile = "wcdev"
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"
  }

  alias  = "storage"
  region = var.region

  profile = "wellcome-az"
}

terraform {
  required_version = ">= 0.14"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/stage/terraform.tfstate"
    region = "eu-west-1"

    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"

    profile = "wcdev"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.21.0"
    }
  }
}