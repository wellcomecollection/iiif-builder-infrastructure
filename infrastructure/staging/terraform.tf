provider "aws" {
  version = "~> 2.46"
  region  = var.region
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/stage/terraform.tfstate"
    #dynamodb_table = "terraform-stage-locktable"
    region = "eu-west-1"
  }
}

# resource "aws_dynamodb_table" "terraform-stage-locktable" {
#   name           = "terraform-stage-locktable"
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }