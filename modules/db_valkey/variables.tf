
locals {
  subnet_ids = [for s in var.subnets : s.id]
}

variable "name" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "7.1"
}

# https://aws.amazon.com/elasticache/pricing/
# https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/CacheNodes.SupportedTypes.html
variable "machine_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

# TODO
variable "subnets" {
  default = []
}

variable "passwords" {
  type = list(string)
}

variable "tag_app" {
  type    = string
  default = "SOMEAPP"
}
