data "aws_sns_topic" "registered_bag_notification" {
  provider = aws.storage

  name = "storage-staging_registered_bag_notifications"
}

resource "aws_sqs_queue" "registered_bag_queue" {
  name = "wellcomecollection-stage-registered-bag-notification"
}

resource "aws_sns_topic_subscription" "registered_bag" {
  topic_arn = data.aws_sns_topic.registered_bag_notification.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.registered_bag_queue.arn
}

resource "aws_sqs_queue_policy" "registered_bag_policy" {
  queue_url = aws_sqs_queue.registered_bag_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqs-registered-bag-staging",
  "Statement": [
    {
      "Sid": "sns-to-sqs",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.registered_bag_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${data.aws_sns_topic.registered_bag_notification.arn}"
        }
      }
    }
  ]
}
POLICY
}
