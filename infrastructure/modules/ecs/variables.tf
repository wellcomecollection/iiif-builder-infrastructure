locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Environment" = var.environment
    "Terraform"   = true
    "Name"        = "${var.name}-${var.environment}"
  }

  full_name = "${var.name}-${var.environment}"
}

variable "name" {
  description = "Name to use on resource tags"
}

variable "environment" {
  description = "Environment for resources (e.g. staging, production)"
}

variable "docker_repository_url" {
  description = "URL to repository containing docker image"
}

variable "docker_tag" {
  description = "Docker tag to use"
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "ecs_cluster_arn" {
  description = "ARN of cluster to host services on"
}

variable "container_port" {
  type = number
}

variable "service_discovery_namespace_id" {
}

variable "service_subnets" {
  type = list(string)
}

variable "service_security_group_ids" {
  type = list(string)
}

variable "healthcheck_path" {
}

variable "vpc_id" {
}

variable "lb_listener_arn" {
}

variable "lb_zone_id" {}

variable "lb_fqdn" {}

variable "path_patterns" {
  type        = list(string)
  description = "Path patterns to match in ALB"
  default = [
    "/*",
  ]
}

variable "listener_priority" {
  type = number
}

variable "hostname" {
  description = "(Optional) Hostname to register in Route53"
  default     = ""
}

variable "domain" {
  description = "Path patterns to match in ALB"
}

variable "zone_id" {
  description = "Route53 zone Id"
}