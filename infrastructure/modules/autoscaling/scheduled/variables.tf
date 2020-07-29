locals {
  resource_id = "service/${var.cluster_name}/${var.service_name}"
}

variable "cluster_name" {
  description = "Name of cluster services running on"
}

variable "service_name" {
  description = "Name of ECS service to scale"
}

variable "scale_up_min" {
  description = "Minimum capacity when scaled up"
  default     = 1
}

variable "scale_up_max" {
  description = "Maximum capacity when scaled up"
  default     = 1
}

variable "scale_down_min" {
  description = "Minimum capacity when scaled down"
  default     = 0
}

variable "scale_down_max" {
  description = "Maximum capacity when scaled up"
  default     = 0
}

variable "scale_up_schedule" {
  description = "When to scale up. The following formats are supported: At expressions - at(yyyy-mm-ddThh:mm:ss), Rate expressions - rate(valueunit), Cron expressions - cron(fields)"
  default = "cron(0 7 * * *)"
}

variable "scale_down_schedule" {
  description = "When to scale down. The following formats are supported: At expressions - at(yyyy-mm-ddThh:mm:ss), Rate expressions - rate(valueunit), Cron expressions - cron(fields)"
  default = "cron(0 19 * * *)"
}