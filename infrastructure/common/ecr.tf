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