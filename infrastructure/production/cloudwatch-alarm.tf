resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name         = "${local.full_name}_rds_connections"
  alarm_description  = "IIIF Builder RDS high connection count"
  evaluation_periods = 2
  period             = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  statistic           = "Maximum"
  threshold           = 50 # normally sit around 10
  dimensions = {
    DBInstanceIdentifier = module.rds.db_name
  }

  ok_actions    = [data.terraform_remote_state.dlcs.outputs.cloudwatch_alarm_topic_arn]
  alarm_actions = [data.terraform_remote_state.dlcs.outputs.cloudwatch_alarm_topic_arn]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_dbload" {
  alarm_name         = "${local.full_name}_dbload"
  alarm_description  = "IIIF Builder RDS high DBLoad"
  evaluation_periods = 2
  period             = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "DBLoad"
  namespace           = "AWS/RDS"
  statistic           = "Maximum"
  threshold           = 60 # normally sit around 3
  dimensions = {
    DBInstanceIdentifier = module.rds.db_name
  }

  ok_actions    = [data.terraform_remote_state.dlcs.outputs.cloudwatch_alarm_topic_arn]
  alarm_actions = [data.terraform_remote_state.dlcs.outputs.cloudwatch_alarm_topic_arn]

  treat_missing_data = "notBreaching"
}