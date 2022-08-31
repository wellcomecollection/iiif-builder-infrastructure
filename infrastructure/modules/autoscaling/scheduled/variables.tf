locals {
  resource_id = "service/${var.cluster_name}/${var.service_name}"
}

variable "cluster_name" {
  description = "Name of cluster services running on"
}

variable "service_name" {
  description = "Name of ECS service to scale"
}

variable "scale_out_min" {
  description = "Minimum capacity when scaled out"
  default     = 1
}

variable "scale_out_max" {
  description = "Maximum capacity when scaled out"
  default     = 1
}

variable "scale_in_min" {
  description = "Minimum capacity when scaled in"
  default     = 0
}

variable "scale_in_max" {
  description = "Maximum capacity when scaled in"
  default     = 0
}

# see: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "scale_out_schedule" {
  description = "When to scale out. The following formats are supported: At expressions - at(yyyy-mm-ddThh:mm:ss), Rate expressions - rate(valueunit), Cron expressions - cron(fields)"
  default = "cron(0 7 ? * MON-FRI *)"
}

variable "scale_in_schedule" {
  description = "When to scale in. The following formats are supported: At expressions - at(yyyy-mm-ddThh:mm:ss), Rate expressions - rate(valueunit), Cron expressions - cron(fields)"
  default = "cron(0 18 ? * MON-FRI *)"
}