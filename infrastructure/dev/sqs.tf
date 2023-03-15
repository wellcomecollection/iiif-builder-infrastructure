resource "aws_sqs_queue" "born_digital_notifications_dev" {
  name = "born-digital-notifications-dev"
  message_retention_seconds  = 7200
}

resource "aws_sqs_queue" "digitised_notifications_dev" {
  name = "digitised-notifications-dev"
  message_retention_seconds  = 7200
}
