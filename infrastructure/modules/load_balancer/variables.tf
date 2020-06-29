locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Environment" = var.environment
    "Terraform"   = true
    "Name"        = "${var.name}-${var.environment}"
  }

  full_name = "${var.name}-${var.environment}"
}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
}

variable "certificate_domain" {
  description = "Domain existing certificate has been issued for"
}

variable "service_lb_security_group_ids" {
  type = list(string)
}

variable "lb_controlled_ingress_cidrs" {
  type        = list(string)
  description = "A list of CIDRs to restrict http+https ingress access to"
}

variable "name" {
  description = "Name to use on resource tags"
}

variable "environment" {
  description = "Environment for resources (e.g. staging, production)"
}