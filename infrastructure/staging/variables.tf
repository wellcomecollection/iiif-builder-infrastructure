data "aws_caller_identity" "current" {}

locals {
  environment     = "stage"
  environment_alt = "stageprd"
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

  stage_prod_temp_envvars = {
    Dlcs__SkeletonNamedQueryTemplate  = "https://porch.dlcs.io/iiif-resource/wellcome/preview/{0}/{1}"
    Dlcs__SingleAssetManifestTemplate = "https://porch.dlcs.io/iiif-manifest/wellcome/{0}/{1}"
    Dlcs__ApiEntryPoint               = "https://papi.dlcs.io/"
    Dlcs__InternalResourceEntryPoint  = "https://porch.dlcs.io/"
  }
}

variable "region" {
  default = "eu-west-1"
}
