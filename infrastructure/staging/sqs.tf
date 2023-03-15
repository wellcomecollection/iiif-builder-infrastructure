# the platform-created queue (available in both accounts - we don't want to use this, we'll make our own
# data "aws_sqs_queue" "born_digital_notifications_staging_queue" {
#   name = "born-digital-notifications-staging"
# }

# data "aws_sqs_queue" "born_digital_notifications_prod_queue" {
#   name = "born-digital-notifications-prod"
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

# data "aws_iam_policy_document" "born_digital_notifications_prod_read_from_queue" {
#   statement {
#     actions = [
#       "sqs:DeleteMessage",
#       "sqs:ReceiveMessage",
#       "sqs:GetQueueUrl",
#     ]

#     resources = [
#       data.aws_sqs_queue.born_digital_notifications_prod_queue.arn
#     ]
#   }
# }


# born-digital, staging

resource "aws_sqs_queue" "born_digital_notifications_staging" {
  name = "born-digital-notifications-staging-dds"  # while the other one still exists
  message_retention_seconds  = 7200
}

data "aws_iam_policy_document" "born_digital_notifications_staging_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging.arn
    ]
  }
}

data "aws_iam_policy_document" "born_digital_notifications_staging_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging.arn
    ]
  }
}


# digitised, staging

resource "aws_sqs_queue" "digitised_notifications_staging" {
  name = "digitised-notifications-staging-dds"  # while the other one still exists
  message_retention_seconds  = 7200
}

data "aws_iam_policy_document" "digitised_notifications_staging_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging.arn
    ]
  }
}

data "aws_iam_policy_document" "digitised_notifications_staging_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging.arn
    ]
  }
}


# born-digital, staging-prod

resource "aws_sqs_queue" "born_digital_notifications_staging_prod" {
  name = "born-digital-notifications-staging-prod"
  message_retention_seconds  = 7200
}

data "aws_iam_policy_document" "born_digital_notifications_staging_prod_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging_prod.arn
    ]
  }
}

data "aws_iam_policy_document" "born_digital_notifications_staging_prod_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.born_digital_notifications_staging_prod.arn
    ]
  }
}


# digitised, staging-prod

resource "aws_sqs_queue" "digitised_notifications_staging_prod" {
  name = "digitised-notifications-staging-prod"
  message_retention_seconds  = 7200
}

data "aws_iam_policy_document" "digitised_notifications_staging_prod_read_from_queue" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging_prod.arn
    ]
  }
}

data "aws_iam_policy_document" "digitised_notifications_staging_prod_write_to_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.digitised_notifications_staging_prod.arn
    ]
  }
}



# Now subscribe our queues to the PLATFORM and WORKFLOW topics

# born digital, staging

resource "aws_sns_topic_subscription" "born_digital_notifications_staging_subscribes_topic" {
  topic_arn = data.aws_sns_topic.born_digital_bag_notifications_staging.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.born_digital_notifications_staging.arn
}

# And allow the platform topics to write to them:

resource "aws_sqs_queue_policy" "platform_born_digital_bag_notifications_write_to_staging_queue" {
  queue_url = aws_sqs_queue.born_digital_notifications_staging.id
  policy    = data.aws_iam_policy_document.platform_born_digital_bag_notifications_write_to_staging_queue.json
}

data "aws_iam_policy_document" "platform_born_digital_bag_notifications_write_to_staging_queue" {
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
      aws_sqs_queue.born_digital_notifications_staging.arn,
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


# digitised, staging

resource "aws_sns_topic_subscription" "digitised_notifications_staging_subscribes_topic" {
  topic_arn = data.aws_sns_topic.digitised_bag_notifications_workflow_staging.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.digitised_notifications_staging.arn
}

resource "aws_sqs_queue_policy" "workflow_digitised_bag_notifications_write_to_staging_queue" {
  queue_url = aws_sqs_queue.digitised_notifications_staging.id
  policy    = data.aws_iam_policy_document.workflow_digitised_bag_notifications_write_to_staging_queue.json
}

data "aws_iam_policy_document" "workflow_digitised_bag_notifications_write_to_staging_queue" {
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
      aws_sqs_queue.digitised_notifications_staging.arn,
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


# born digital, staging-prod

resource "aws_sns_topic_subscription" "born_digital_notifications_staging_prod_subscribes_topic" {
  topic_arn = data.aws_sns_topic.born_digital_bag_notifications_prod.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.born_digital_notifications_staging_prod.arn
}

# And allow the platform topics to write to them:

resource "aws_sqs_queue_policy" "platform_born_digital_bag_notifications_write_to_test_queue" {
  queue_url = aws_sqs_queue.born_digital_notifications_staging_prod.id
  policy    = data.aws_iam_policy_document.platform_born_digital_bag_notifications_write_to_test_queue.json
}

data "aws_iam_policy_document" "platform_born_digital_bag_notifications_write_to_test_queue" {
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
      aws_sqs_queue.born_digital_notifications_staging_prod.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"


      values = [
        data.aws_sns_topic.born_digital_bag_notifications_prod.arn
      ]
    }
  }
}
