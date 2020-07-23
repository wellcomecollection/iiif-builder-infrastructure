resource "aws_security_group" "staging" {
  name        = "iiif-builder-staging-security-group"
  description = "Allow traffic"
  vpc_id      = local.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = true
    Name        = "iiif-builder-staging-security-group",
    Project     = "iiif-builder",
    Environment = "stage"
  }
}

module "load_balancer" {
  source = "../modules/load_balancer"

  name        = "iiif-builder"
  environment = "stage"

  public_subnets = local.vpc_public_subnets
  vpc_id         = local.vpc_id

  service_lb_security_group_ids = [
    aws_security_group.staging.id,
  ]

  certificate_domain = "dlcs.io"

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

resource "aws_ecr_repository" "iiif_builder" {
  name = "iiif-builder"
  tags = {
    Terraform = true
    Project   = "iiif-builder"
  }
}

resource "aws_ecr_repository" "dashboard" {
  name = "iiif-builder-dashboard"
  tags = {
    Terraform = true
    Project   = "iiif-builder"
  }
}

resource "aws_ecr_repository" "workflow_processor" {
  name = "workflow-processor"
  tags = {
    Terraform = true
    Project   = "iiif-builder"
  }
}

resource "aws_ecr_repository" "job_processor" {
  name = "job-processor"
  tags = {
    Terraform = true
    Project   = "iiif-builder"
  }
}

data "template_file" "public_key" {
  template = file("files/key.pub")
}

resource "aws_key_pair" "auth" {
  key_name   = "iiif-builder"
  public_key = data.template_file.public_key.rendered

  lifecycle {
    create_before_destroy = true
  }
}

module "bastion" {
  source = "../modules/ec2/bastion"

  name          = "iiif-builder"
  instance_type = "t2.micro"
  ami           = "ami-047bb4163c506cd98"

  vpc_id                     = local.vpc_id
  subnets                    = local.vpc_public_subnets
  service_security_group_ids = [aws_security_group.staging.id]
  key_name                   = "iiif-builder"
  ip_whitelist = [
    "62.254.125.26/32" # Glasgow VPN
  ]
}

resource "aws_service_discovery_private_dns_namespace" "iiif_builder" {
  name        = "iiif_builder"
  description = "Private ServiceDiscovery namespace for iiif-builder apps"
  vpc         = local.vpc_id

  tags = {
    Terraform = true
    Name      = "iiif-builder",
    Project   = "iiif-builder"
  }
}