data "aws_sns_topic" "iiif_invalidate_cache" {
  provider = aws.storage

  name = "iiif-prod-cloudfront-invalidate"
}

data "aws_sns_topic" "api_invalidate_cache" {
  provider = aws.storage

  name = "api-prod-cloudfront-invalidate"
}

# access to SNS topics for iiif.wc.org + api.wc.org cache-invalidation
data "aws_iam_policy_document" "invalidate_cache_publish" {
  statement {
    actions = [
      "sns:Publish",
      "sns:SendMessage",
    ]

    resources = [
      data.aws_sns_topic.iiif_invalidate_cache.arn,
      data.aws_sns_topic.api_invalidate_cache.arn
    ]
  }
}


data "aws_sns_topic" "born_digital_bag_notifications" {
  provider = aws.storage

  name = "born-digital-bag-notifications-prod"
}

# Will be for Goobi topic
# data "aws_sns_topic" "digitised_bag_notifications" {
#   provider = aws.storage

#   name = "digitised-bag-notifications-prod"
# }