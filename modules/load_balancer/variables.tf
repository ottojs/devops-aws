
locals {
  subnet_ids = [for s in var.subnets : s.id]
}

variable "name" {
  type = string
}

variable "public" {
  type    = bool
  default = false
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "subnets" {
  type    = list(object({ id = string }))
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "root_domain" {
  type = string
}

variable "log_bucket" {
  type = object({
    id  = string
    arn = string
  })
  description = "S3 Log Bucket Object"
}

variable "log_retention_days" {
  type = number
}

variable "tags" {
  type = map(string)
}
