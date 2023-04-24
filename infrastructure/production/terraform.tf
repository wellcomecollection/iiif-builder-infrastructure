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

  alias  = "platform"
  region = var.region

  profile = "wellcome-az"
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::975596993436:role/storage-read_only"
  }

  alias  = "storage"
  region = var.region

  profile = "wellcome-az"
}


provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::299497370133:role/workflow-read_only"
  }

  alias  = "workflow"
  region = var.region

  profile = "wellcome-az"
}


terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/production/terraform.tfstate"
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