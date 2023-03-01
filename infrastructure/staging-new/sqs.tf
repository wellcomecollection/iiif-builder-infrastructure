
# we don't want to use this queue for staging-new - in fact we don't want to use this queue anywhere, we want to create our own queue and subscribe to it.

# data "aws_sqs_queue" "born_digital_notifications_staging_queue" {
#   name = "born-digital-notifications-staging"
# }

# data "aws_iam_policy_document" "born_digital_notifications_staging_read_from_queue" {
#   statement {
#     actions = [
#       "sqs:DeleteMessage",
#       "sqs:ReceiveMessage",
#       "sqs:GetQueueUrl",
#     ]

#     resources = [
#       data.aws_sqs_queue.born_digital_notifications_staging_queue.arn
#     ]
#   }
# }

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

# This will be the Goobi version, when the topic becomes available:
# resource "aws_sns_topic_subscription" "digitised_notifications_staging_new_subscribes_topic" {
#   topic_arn = aws_sns_topic.digitised_bag_notifications_staging.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.digitised_notifications_staging_new.arn
# }