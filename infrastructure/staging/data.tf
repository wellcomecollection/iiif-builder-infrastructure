# remote state for common
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = "dlcs-remote-state"
    key    = "iiif-builder/common/terraform.tfstate"
    region = "eu-west-1"
  }
}