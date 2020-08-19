resource "aws_appautoscaling_target" "service_scale_target" {
  service_namespace  = "ecs"
  resource_id        = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.scale_out_min
  max_capacity       = var.scale_out_max
}

resource "aws_appautoscaling_scheduled_action" "scale_out" {
  name               = "scale-up-${var.service_name}"
  service_namespace  = aws_appautoscaling_target.service_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.service_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_scale_target.scalable_dimension
  schedule           = var.scale_out_schedule

  scalable_target_action {
    min_capacity = var.scale_out_min
    max_capacity = var.scale_out_max
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_in" {
  name               = "scale-down-${var.service_name}"
  service_namespace  = aws_appautoscaling_target.service_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.service_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_scale_target.scalable_dimension
  schedule           = var.scale_in_schedule

  scalable_target_action {
    min_capacity = var.scale_in_min
    max_capacity = var.scale_in_max
  }
}