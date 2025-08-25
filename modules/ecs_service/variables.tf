data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster
data "aws_ecs_cluster" "main" {
  cluster_name = var.ecs_cluster
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb
data "aws_lb" "main" {
  count = var.mode == "server" ? 1 : 0
  name  = "alb-${var.public == true ? "public" : "private"}"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_listener
data "aws_lb_listener" "https" {
  count             = var.mode == "server" ? 1 : 0
  load_balancer_arn = data.aws_lb.main[0].arn
  port              = 443
}

#####
#####

# Valid Values
# server, worker, cron
variable "mode" {
  type = string
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

variable "replicas" {
  type    = number
  default = 1
}

variable "tag" {
  type    = string
  default = "latest"
}

# FARGATE or EC2
variable "type" {
  type = string
}

variable "command" {
  type    = list(string)
  default = null
}

variable "envvars" {
  type = map(string)
}

variable "secrets" {
  type = list(string)
}

variable "fault_injection" {
  type    = bool
  default = false
}

# Will not deploy to ECS when true
# Ideal for creating a registry and IAM roles first
variable "skeleton" {
  type    = bool
  default = false
}

# Creates a registry for this app in ECR
variable "create_registry" {
  type    = bool
  default = true
}

# Allows you to use another app's registry
# Use this with caution
variable "use_registry" {
  type    = string
  default = ""
}

variable "inline_policy" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(string)
}

#######################
##### Server Only #####
#######################

variable "public" {
  type    = bool
  default = false
}

variable "root_domain" {
  type    = string
  default = "example.com"
}

variable "additional_hosts" {
  type    = list(string)
  default = []
}

variable "priority" {
  type    = number
  default = 1
}

variable "health_check_path" {
  type    = string
  default = "/"
}

#######################
##### Cron Job Only ###
#######################

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "schedule" {
  type    = string
  default = "cron(0 0 * * ? *)" # Every day at midnight
}
