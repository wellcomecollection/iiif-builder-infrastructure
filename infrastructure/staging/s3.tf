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