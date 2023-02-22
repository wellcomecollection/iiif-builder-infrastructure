data "aws_sqs_queue" "born_digital_notifications_staging_queue" {
  name = "born-digital-notifications-staging"
}

data "aws_sqs_queue" "born_digital_notifications_prod_queue" {
  name = "born-digital-notifications-prod"
}

data "aws_iam_policy_document" "born_digital_notifications_staging_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      data.aws_sqs_queue.born_digital_notifications_staging_queue.arn
    ]
  }
}

data "aws_iam_policy_document" "born_digital_notifications_prod_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      data.aws_sqs_queue.born_digital_notifications_prod_queue.arn
    ]
  }
}
