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

variable "docker_image" {
  description = "Image to use for main container"
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

variable "service_discovery_namespace_id" {
  default = null
}

variable "service_subnets" {
  type = list(string)
}

variable "service_security_group_ids" {
  type = list(string)
}

variable "vpc_id" {
}

variable "port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  default = []
}

variable "secret_env_vars" {
  description = "Path of secrets to be passed from SecretManager"
  type        = map(string)
  default     = {}
}

variable "env_vars" {
  description = "Variables to be set as environment variables"
  type        = map(string)
  default     = {}
}

variable "healthcheck" {
  type = object({
    command     = list(string)
    retries     = number
    timeout     = number
    interval    = number
    startPeriod = number
  })

  default = null
}

variable "desired_count"{
  description = "Number of tasks to run"
  default     = 1
}