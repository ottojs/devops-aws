data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate
data "aws_acm_certificate" "main" {
  domain   = "*.${var.root_domain}"
  statuses = ["ISSUED"]
}

locals {
  # We need only one subnet, possibly because of the cluster number
  subnet_ids = [var.subnet_ids[0]]
}

variable "name" {
  type = string
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "root_domain" {
  type = string
}

variable "opensearch_version" {
  type    = string
  default = "2.19"
}

variable "username" {
  type    = string
  default = "admin"
}

# This is a path to secret in Secrets Manager, do not put password here
# password must contain at least one:
# - uppercase letter
# - lowercase letter
# - number
# - special character
variable "password" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_size" {
  type    = string
  default = "t3.small.search"
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "tags" {
  type = map(string)
}
