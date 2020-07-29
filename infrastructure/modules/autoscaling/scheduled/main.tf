# AWS provided role for ECS app autoscaling
data "aws_iam_role" "ecs_autoscaling" {
  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
}

resource "aws_appautoscaling_target" "service_scale_target" {
  service_namespace  = "ecs"
  resource_id        = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = data.aws_iam_role.ecs_autoscaling.arn
  min_capacity       = var.scale_down_min
  max_capacity       = var.scale_up_max
}

resource "aws_appautoscaling_scheduled_action" "scale_up" {
  name               = "scale-up-${var.service_name}"
  service_namespace  = aws_appautoscaling_target.service_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.service_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_scale_target.scalable_dimension
  schedule           = var.scale_up_schedule

  scalable_target_action {
    min_capacity = var.scale_up_min
    max_capacity = var.scale_up_max
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_down" {
  name               = "scale-down-${var.service_name}"
  service_namespace  = aws_appautoscaling_target.service_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.service_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_scale_target.scalable_dimension
  schedule           = var.scale_up_schedule

  scalable_target_action {
    min_capacity = var.scale_down_min
    max_capacity = var.scale_down_max
  }
}