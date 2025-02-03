data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  subnet_ids = [for s in var.subnets : s.id]
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

# TODO
variable "subnets" {
  default = []
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "ecs_cluster" {
  type = object({
    id   = string
    name = string
    arn  = string
  })
}

# FARGATE or EC2
variable "type" {
  type = string
}

# X86_64 or ARM64
variable "arch" {
  type    = string
  default = "X86_64"
}

# Fargate Resource Combinations
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
variable "cpu" {
  type    = number
  default = 256
}

variable "ram" {
  type    = number
  default = 512
}

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "schedule" {
  type = string
}

variable "tag" {
  type    = string
  default = "latest"
}

variable "tag_app" {
  type = string
}
