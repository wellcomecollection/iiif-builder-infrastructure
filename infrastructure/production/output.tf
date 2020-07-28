output "dashboard_role_id" {
  value = data.aws_iam_role.dashboard_task_role.unique_id
}

output "workflowprocessor_role_id" {
  value = data.aws_iam_role.workflowprocessor_task_role.unique_id
}

output "jobprocessor_role_id" {
  value = data.aws_iam_role.jobprocessor_task_role.unique_id
}

output "iiifbuilder_role_id" {
  value = data.aws_iam_role.iiifbuilder_task_role.unique_id
}
