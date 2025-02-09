
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

variable "subnets" {
  type    = list(object({ id = string }))
  default = []
}

variable "passwords" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
