# remote-state for Wellcome shared platform-infra
# https://github.com/wellcomecollection/platform-infrastructure/tree/master/critical/back_end

data "terraform_remote_state" "platform_infra" {
  backend = "s3"

  config = {
    bucket   = "wellcomecollection-platform-infra"
    key      = "terraform/platform-infrastructure/shared.tfstate"
    region   = "eu-west-1"
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"    
  }
}