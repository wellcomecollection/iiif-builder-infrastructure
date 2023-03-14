resource "aws_sqs_queue" "born_digital_notifications_staging_new" {
  name = "born-digital-notifications-staging-new"
  message_retention_seconds  = 7200
}


data "aws_iam_policy_document" "born_digital_notifications_staging_new_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging_new.arn
    ]
  }
}

data "aws_iam_policy_document" "born_digital_notifications_staging_new_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging_new.arn
    ]
  }
}


resource "aws_sqs_queue" "digitised_notifications_staging_new" {
  name = "digitised-notifications-staging-new"
  message_retention_seconds  = 7200
}


data "aws_iam_policy_document" "digitised_notifications_staging_new_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging_new.arn
    ]
  }
}

data "aws_iam_policy_document" "digitised_notifications_staging_new_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging_new.arn
    ]
  }
}

# Now subscribe our queues to the PLATFORM topics
resource "aws_sns_topic_subscription" "born_digital_notifications_staging_new_subscribes_topic" {
  topic_arn = data.aws_sns_topic.born_digital_bag_notifications_staging.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.born_digital_notifications_staging_new.arn
}

resource "aws_sns_topic_subscription" "digitised_notifications_staging_new_subscribes_topic" {
  topic_arn = aws_sns_topic.digitised_bag_notifications_workflow_staging.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.digitised_notifications_staging_new.arn
}

# And allow the platform topics to write to them:

resource "aws_sqs_queue_policy" "platform_born_digital_bag_notifications_write_to_queue" {
  queue_url = aws_sqs_queue.born_digital_notifications_staging_new.id
  policy    = data.aws_iam_policy_document.platform_born_digital_bag_notifications_write_to_queue.json
}

data "aws_iam_policy_document" "platform_born_digital_bag_notifications_write_to_queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging_new.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"


      values = [
        data.aws_sns_topic.born_digital_bag_notifications_staging.arn
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "workflow_digitised_bag_notifications_write_to_queue" {
  queue_url = aws_sqs_queue.digitised_notifications_staging_new.id
  policy    = data.aws_iam_policy_document.workflow_digitised_bag_notifications_write_to_queue.json
}

data "aws_iam_policy_document" "workflow_digitised_bag_notifications_write_to_queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging_new.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"


      values = [
        data.aws_sns_topic.digitised_bag_notifications_workflow_staging.arn
      ]
    }
  }
}