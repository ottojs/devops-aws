data "aws_region" "current" {}

variable "name" {
  type        = string
  description = "VPC Name"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "cidr" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
  description = "KMS Key Object"
}

variable "log_bucket" {
  type = object({
    id = string
  })
}

variable "subnets_public" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "subnets_private" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "log_retention_days" {
  type = number
}

variable "vpc_endpoints" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}
