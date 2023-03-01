data "aws_sns_topic" "iiif_stage_new_invalidate_cache" {
  provider = aws.platform

  name = "iiif-stage-new-cloudfront-invalidate"
}

data "aws_sns_topic" "born_digital_bag_notifications_staging" {
  provider = aws.storage

  name = "born-digital-bag-notifications-staging"
}

# This doesn't exist yet but is the presumed name for the Goobi staging topic
# data "aws_sns_topic" "digitised_bag_notifications_staging" {
#   provider = aws.storage  # may be different - intranda?

#   name = "digitised-bag-notifications-staging"
# }

# access to SNS topic for iiif-stage-new.wc.org cache-invalidation
data "aws_iam_policy_document" "iiif_stage_new_invalidate_cache_publish" {
  statement {
    actions = [
      "sns:Publish",
      "sns:SendMessage",
    ]

    resources = [
      data.aws_sns_topic.iiif_stage_new_invalidate_cache.arn
    ]
  }
}

