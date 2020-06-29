resource "aws_ecr_repository" "iiif_builder" {
  name = "iiif-builder"
  tags = {
    Terraform = true
  }
}