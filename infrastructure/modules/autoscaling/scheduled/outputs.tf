output "scale_down_arn" {
  value = aws_appautoscaling_scheduled_action.scale_down.arn
}

output "scale_up_arn" {
  value = aws_appautoscaling_scheduled_action.scale_up.arn
}
