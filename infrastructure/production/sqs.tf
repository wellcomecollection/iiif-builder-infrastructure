resource "aws_sqs_queue" "born_digital_notifications" {
  name = "born-digital-notifications"
  message_retention_seconds  = 7200
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
  name = "digitised-notifications"
  message_retention_seconds  = 7200
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

# Now subscribe our queues to the PLATFORM topics
resource "aws_sns_topic_subscription" "born_digital_notifications_subscribes_topic" {
  topic_arn = data.aws_sns_topic.born_digital_bag_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.born_digital_notifications.arn
}

# This will be the Goobi version, when the topic becomes available:
# resource "aws_sns_topic_subscription" "digitised_notifications_subscribes_topic" {
#   topic_arn = aws_sns_topic.digitised_bag_notifications.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.digitised_notifications.arn
# }

# And allow the platform topics to write to them:

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

# And same for Goobi, when it's available:

# resource "aws_sqs_queue_policy" "platform_digitised_bag_notifications_write_to_queue" {
#   queue_url = aws_sqs_queue.digitised_notifications.id
#   policy    = data.aws_iam_policy_document.platform_digitised_bag_notifications_write_to_queue.json
# }

# data "aws_iam_policy_document" "platform_digitised_bag_notifications_write_to_queue" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     actions = [
#       "sqs:SendMessage",
#     ]

#     resources = [
#       aws_sqs_queue.digitised_notifications.arn,
#     ]

#     condition {
#       test     = "ArnEquals"
#       variable = "aws:SourceArn"


#       values = [
#         data.aws_sns_topic.digitised_bag_notifications.arn
#       ]
#     }
#   }
# }