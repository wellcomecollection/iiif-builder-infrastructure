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

variable "db_creds_secret_key" {
  description = "Key of Secret containing admin DB credentials"
}

variable "db_security_group_ids" {
  type        = list(string)
  description = ""
}

variable "db_engine_version" {
  type        = string
  description = "Postgres version to use"
  default     = "12.3"
}

variable "identifier_postfix" {
  type        = string
  description = "Postfix to add to DB name, useful when doing rolling updates"
  default     = ""
}

variable "db_cert_authority" {
  type        = string
  description = "Certificate authority identifier"
  default     = "rds-ca-2019"
}
