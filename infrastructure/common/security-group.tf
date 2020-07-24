resource "aws_security_group" "staging" {
  name        = "iiif-builder-staging-security-group"
  description = "Allow traffic"
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

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

resource "aws_security_group" "production" {
  name        = "iiif-builder-production-security-group"
  description = "Allow traffic"
  vpc_id      = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_id

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
    Name        = "iiif-builder-production-security-group",
    Project     = "iiif-builder",
    Environment = "production"
  }
}