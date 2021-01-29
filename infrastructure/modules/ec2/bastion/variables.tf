locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Terraform" = true
    "Name"      = var.name
  }
}

variable "name" {
  description = "Name to use on resource tags"
}

variable "instance_type" {
}

variable "ami" {
  description = "ARN of cluster to host services on"
}

variable "subnets" {
  type = list(string)
}

variable "service_security_group_ids" {
  type = list(string)
}

variable "vpc_id" {
}

variable "key_name" {}

variable "ip_whitelist" {
  description = "List of IP addresses to allow access"
}