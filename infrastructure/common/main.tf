module "load_balancer" {
  source = "../modules/load_balancer"

  name        = "iiif-builder"
  environment = "shared"

  public_subnets = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_public_subnets
  vpc_id         = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  service_lb_security_group_ids = [
    aws_security_group.staging.id,
    aws_security_group.production.id
  ]

  certificate_arn = module.cert.arn

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

resource "aws_key_pair" "auth" {
  key_name   = "iiif-builder"
  public_key = file("files/key.pub")

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "bastion_host_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["weco-amzn2-hvm-x86_64*"]
  }
}

module "bastion" {
  source = "../modules/ec2/bastion"

  name          = "iiif-builder"
  instance_type = "t2.micro"
  ami           = data.aws_ami.bastion_host_ami.id

  vpc_id                     = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id
  subnets                    = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_public_subnets
  service_security_group_ids = [aws_security_group.staging.id, aws_security_group.production.id]
  key_name                   = "iiif-builder"
  ip_whitelist = [
    "62.254.125.26/31", # Glasgow
    "62.254.125.28/30", # Glasgow
  ]
}

resource "aws_service_discovery_private_dns_namespace" "iiif_builder" {
  name        = "iiif_builder"
  description = "Private ServiceDiscovery namespace for iiif-builder apps"
  vpc         = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

  tags = local.common_tags
}