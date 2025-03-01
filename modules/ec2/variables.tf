data "aws_region" "current" {}

locals {
  name = "${var.name}-${var.os}-${var.arch}"
  # https://aws.amazon.com/ec2/instance-types/t3/
  # https://aws.amazon.com/ec2/instance-types/t4/
  instance_type = {
    x86_64 = "t3a.micro"
    arm64  = "t4g.micro"
  }
}

variable "name" {
  type = string
}

variable "machine" {
  type    = string
  default = ""
}

variable "arch" {
  type    = string
  default = "x86_64"
}

variable "os" {
  type    = string
  default = "al2023_250218"
}

variable "azs" {
  type    = list(string)
  default = ["a", "b", "c"]
}

variable "ssh_key" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type = string
}

variable "access" {
  type    = string
  default = "private"
}

variable "userdata" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "security_groups" {
  type = list(string)
}

variable "iam_instance_profile" {
  type = object({
    name = string
  })
}

variable "tags" {
  type = map(string)
}
