
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

variable "maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:09:00"
  description = "Weekly maintenance window in UTC"
}

variable "snapshot_window" {
  type        = string
  default     = "00:00-04:00"
  description = "Daily snapshot window in UTC"
}

variable "snapshot_retention_limit" {
  type        = number
  default     = 10
  description = "Number of days to retain snapshots"
}
