data "aws_sns_topic" "iiif_stage_new_invalidate_cache" {
  provider = aws.platform

  name = "iiif-stage-new-cloudfront-invalidate"
}

data "aws_sns_topic" "born_digital_bag_notifications_staging" {
  provider = aws.platform

  name = "born-digital-bag-notifications-staging"
}

data "aws_sns_topic" "digitised_bag_notifications_workflow_staging" {
  provider = aws.workflow

  name = "digitised-bag-notifications-workflow-staging"
}

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

