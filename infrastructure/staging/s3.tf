# access to wellcome-collection storage. Needs corresponding perms in wellcome account
data "aws_iam_policy_document" "wellcomecollection_storage_bucket_read" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::wellcomecollection-storage",
      "arn:aws:s3:::wellcomecollection-storage/*",
    ]
  }
}

# access to wellcome-collection storage. Needs corresponding perms in wellcome account
data "aws_iam_policy_document" "wellcomecollection_storage_staging_bucket_read" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::wellcomecollection-storage-staging",
      "arn:aws:s3:::wellcomecollection-storage-staging/*",
    ]
  }
}

# Storage Maps
resource "aws_s3_bucket" "storagemaps" {
  bucket = "wellcomecollection-stage-iiif-storagemaps"
  acl    = "private"
}

data "aws_iam_policy_document" "storagemaps_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.storagemaps.arn,
      "${aws_s3_bucket.storagemaps.arn}/*",
    ]
  }
}

# Presentation
resource "aws_s3_bucket" "presentation" {
  bucket = "wellcomecollection-stage-iiif-presentation"
  acl    = "private"
}

data "aws_iam_policy_document" "presentation_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.presentation.arn,
      "${aws_s3_bucket.presentation.arn}/*",
    ]
  }
}

# Text
resource "aws_s3_bucket" "text" {
  bucket = "wellcomecollection-stage-iiif-text"
  acl    = "private"
}

data "aws_iam_policy_document" "text_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.text.arn,
      "${aws_s3_bucket.text.arn}/*",
    ]
  }
}