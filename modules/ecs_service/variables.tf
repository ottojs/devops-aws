data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster
data "aws_ecs_cluster" "main" {
  cluster_name = var.ecs_cluster
}

data "aws_lb_listener" "https" {
  load_balancer_arn = var.load_balancer.arn
  port              = 443
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

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "ecs_cluster" {
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

variable "tag" {
  type    = string
  default = "latest"
}

variable "root_domain" {
  type = string
}

variable "load_balancer" {
  type = object({
    arn      = string
    dns_name = string
    zone_id  = string
  })
}

variable "public" {
  type    = bool
  default = false
}

# FARGATE or EC2
variable "type" {
  type = string
}

variable "priority" {
  type = number
}

variable "envvars" {
  type = map(string)
}

variable "secrets" {
  type = map(string)
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "fault_injection" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}
