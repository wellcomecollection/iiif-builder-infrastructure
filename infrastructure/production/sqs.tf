resource "aws_sqs_queue" "born_digital_notifications" {
  name                      = "born-digital-notifications"
  message_retention_seconds = 1209600 # 14d
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.born_digital_notifications_dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "born_digital_notifications_dlq" {
  name = "born-digital-notifications-dlq"
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["arn:aws:sqs:${var.region}:${local.account_id}:born-digital-notifications"]
  })
}

data "aws_iam_policy_document" "born_digital_notifications_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications.arn
    ]
  }
}

data "aws_iam_policy_document" "born_digital_notifications_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications.arn
    ]
  }
}


resource "aws_sqs_queue" "digitised_notifications" {
  name                      = "digitised-notifications"
  message_retention_seconds = 1209600 # 14d
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.digitised_notifications_dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "digitised_notifications_dlq" {
  name                      = "digitised-notifications-dlq"
  message_retention_seconds = 1209600 # 14d

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["arn:aws:sqs:${var.region}:${local.account_id}:digitised-notifications"]
  })
}


data "aws_iam_policy_document" "digitised_notifications_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications.arn
    ]
  }
}

data "aws_iam_policy_document" "digitised_notifications_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications.arn
    ]
  }
}

# Now subscribe our queues to the platform (born digital) and workflow (goobi) topics
resource "aws_sns_topic_subscription" "born_digital_notifications_subscribes_topic" {
  topic_arn = data.aws_sns_topic.born_digital_bag_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.born_digital_notifications.arn
}

resource "aws_sns_topic_subscription" "digitised_notifications_subscribes_topic" {
  topic_arn = data.aws_sns_topic.digitised_bag_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.digitised_notifications.arn
}

# And allow those topics to write to them:
resource "aws_sqs_queue_policy" "platform_born_digital_bag_notifications_write_to_queue" {
  queue_url = aws_sqs_queue.born_digital_notifications.id
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
      aws_sqs_queue.born_digital_notifications.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"


      values = [
        data.aws_sns_topic.born_digital_bag_notifications.arn
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "platform_digitised_bag_notifications_write_to_queue" {
  queue_url = aws_sqs_queue.digitised_notifications.id
  policy    = data.aws_iam_policy_document.platform_digitised_bag_notifications_write_to_queue.json
}

data "aws_iam_policy_document" "platform_digitised_bag_notifications_write_to_queue" {
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
      aws_sqs_queue.digitised_notifications.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"


      values = [
        data.aws_sns_topic.digitised_bag_notifications.arn
      ]
    }
  }
}
