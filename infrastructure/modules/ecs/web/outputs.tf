output "task_role_name" {
  value = module.task_definition.task_role_name
}

output "task_role_arn" {
  value = module.task_definition.task_role_arn
}

output "service_target_group_arn"{
  value = aws_alb_target_group.service.arn
}

output "service_name" {
  value = module.service.name
}