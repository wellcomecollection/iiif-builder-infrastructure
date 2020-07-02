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

resource "aws_ecr_repository" "iiif_builder" {
  name = "iiif-builder"
  tags = {
    Terraform = true
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