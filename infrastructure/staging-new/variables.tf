data "aws_caller_identity" "current" {}

locals {
  environment     = "stage-new"
  name            = "iiif-builder"
  full_name       = "${local.name}-${local.environment}"

  # Common tags to be assigned to most resources
  common_tags = {
    "Environment" = local.environment
    "Terraform"   = true
    "Name"        = local.full_name
    "Project"     = local.name
  }

  account_id = data.aws_caller_identity.current.account_id
}

variable "region" {
  default = "eu-west-1"
}