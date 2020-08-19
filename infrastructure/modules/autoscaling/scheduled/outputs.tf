output "scale_in_arn" {
  value = aws_appautoscaling_scheduled_action.scale_in.arn
}

output "scale_out_arn" {
  value = aws_appautoscaling_scheduled_action.scale_out.arn
}
