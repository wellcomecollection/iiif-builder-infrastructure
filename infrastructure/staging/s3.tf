# access to wellcome-collection storage.
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

# access to wellcome-collection storage.
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

data "aws_iam_policy_document" "storagemaps_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.storagemaps.arn,
      "${aws_s3_bucket.storagemaps.arn}/*",
    ]
  }
}

resource "aws_s3_bucket" "storagemaps_test" {
  bucket = "wellcomecollection-test-iiif-storagemaps"
}

data "aws_iam_policy_document" "storagemaps_test_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.storagemaps_test.arn,
      "${aws_s3_bucket.storagemaps_test.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "storagemaps_test_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.storagemaps_test.arn,
      "${aws_s3_bucket.storagemaps_test.arn}/*",
    ]
  }
}

# Presentation
resource "aws_s3_bucket" "presentation" {
  bucket = "wellcomecollection-stage-iiif-presentation"
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

data "aws_iam_policy_document" "presentation_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.presentation.arn,
      "${aws_s3_bucket.presentation.arn}/*",
    ]
  }
}

resource "aws_s3_bucket" "presentation_test" {
  bucket = "wellcomecollection-test-iiif-presentation"
}

data "aws_iam_policy_document" "presentation_test_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.presentation_test.arn,
      "${aws_s3_bucket.presentation_test.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "presentation_test_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.presentation_test.arn,
      "${aws_s3_bucket.presentation_test.arn}/*",
    ]
  }
}

# Text
resource "aws_s3_bucket" "text" {
  bucket = "wellcomecollection-stage-iiif-text"
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

data "aws_iam_policy_document" "text_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.text.arn,
      "${aws_s3_bucket.text.arn}/*",
    ]
  }
}

resource "aws_s3_bucket" "text_test" {
  bucket = "wellcomecollection-test-iiif-text"
}

data "aws_iam_policy_document" "text_test_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.text_test.arn,
      "${aws_s3_bucket.text_test.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "text_test_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.text_test.arn,
      "${aws_s3_bucket.text_test.arn}/*",
    ]
  }
}

# Annotations - per manifest anno lists
resource "aws_s3_bucket" "annotations" {
  bucket = "wellcomecollection-stage-iiif-annotations"
}

data "aws_iam_policy_document" "annotations_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.annotations.arn,
      "${aws_s3_bucket.annotations.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "annotations_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.annotations.arn,
      "${aws_s3_bucket.annotations.arn}/*",
    ]
  }
}

resource "aws_s3_bucket" "annotations_test" {
  bucket = "wellcomecollection-test-iiif-annotations"
}

data "aws_iam_policy_document" "annotations_test_readwrite" {
  statement {
    actions = [
      "s3:*Object",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.annotations_test.arn,
      "${aws_s3_bucket.annotations_test.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "annotations_test_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectVersion"
    ]

    resources = [
      aws_s3_bucket.annotations_test.arn,
      "${aws_s3_bucket.annotations_test.arn}/*",
    ]
  }
}