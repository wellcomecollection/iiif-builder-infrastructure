output "dashboard_role_id" {
  value = data.aws_iam_role.dashboard_task_role.unique_id
}

output "dashboardstgprd_role_id" {
  value = data.aws_iam_role.dashboardstgprd_task_role.unique_id
}