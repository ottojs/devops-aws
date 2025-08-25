
data "aws_sns_topic" "devops" {
  name = "devops"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = true
}

variable "name" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "8.1"
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

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "root_domain" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

# This is a path to secret in Secrets Manager, do not put password here
# 16 to 128 alphanumeric characters or symbols (excluding @, ", and /)
variable "password" {
  type = string
}

# Beware: This is a different mode of operation and some
# applications may not be able to support full cluster mode
variable "cluster_mode" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}
