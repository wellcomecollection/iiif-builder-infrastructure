data "aws_sns_topic" "iiif_test_invalidate_cache" {
  provider = aws.storage

  name = "iiif-test-cloudfront-invalidate"
}

data "aws_sns_topic" "iiif_stage_invalidate_cache" {
  provider = aws.storage

  name = "iiif-stage-cloudfront-invalidate"
}

data "aws_sns_topic" "api_stage_invalidate_cache" {
  provider = aws.storage

  name = "api-stage-cloudfront-invalidate"
}

# access to SNS topic for iiif-test.wc.org cache-invalidation
data "aws_iam_policy_document" "iiif_test_invalidate_cache_publish" {
  statement {
    actions = [
      "sns:Publish",
      "sns:SendMessage",
    ]

    resources = [
      data.aws_sns_topic.iiif_test_invalidate_cache.arn
    ]
  }
}

# access to SNS topic for iiif-stage.wc.org cache-invalidation
data "aws_iam_policy_document" "iiif_stage_invalidate_cache_publish" {
  statement {
    actions = [
      "sns:Publish",
      "sns:SendMessage",
    ]

    resources = [
      data.aws_sns_topic.iiif_stage_invalidate_cache.arn
    ]
  }
}

# access to SNS topic for api-stage.wc.org cache-invalidation
data "aws_iam_policy_document" "api_stage_invalidate_cache_publish" {
  statement {
    actions = [
      "sns:Publish",
      "sns:SendMessage",
    ]

    resources = [
      data.aws_sns_topic.api_stage_invalidate_cache.arn
    ]
  }
}