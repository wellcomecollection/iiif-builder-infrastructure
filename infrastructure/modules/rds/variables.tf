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

variable "vpc_id" {
}

variable "db_instance_class" {
  description = "Instance class for RDS instance"
}

variable "db_storage" {
  type        = number
  description = "Storage, in GiB, to allocate to RDS instance"
}

variable "db_subnets" {
  description = "Subnet Ids for placing RDS instance in"
}

variable "db_ingress_cidrs" {
  type        = list(string)
  description = "A list of CIDRs that can access the RDS instance"
}

variable "db_password_ssm_key" {
  description = "Key of SSM param containing DB password"
}

variable "db_username_ssm_key" {
  description = "Key of SSM param containing DB username"
}

variable "db_security_group_ids" {
  type        = list(string)
  description = ""
}