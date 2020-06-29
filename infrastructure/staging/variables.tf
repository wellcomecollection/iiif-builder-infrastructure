locals {
  # Common tags to be assigned to all resources
  environment = "stage"
  name        = "iiif-builder"
  full_name   = "${local.name}-${local.stage}"

  common_tags = {
    "Environment" = local.environment
    "Terraform"   = true
    "Name"        = "${local.name}-${local.environment}"
  }
}

variable "region" {
  default = "eu-west-1"
}