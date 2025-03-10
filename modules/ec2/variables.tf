data "aws_region" "current" {}

locals {
  name = "${var.name}-${var.os}-${var.arch}"
  # https://aws.amazon.com/ec2/instance-types/t3/
  # https://aws.amazon.com/ec2/instance-types/t4/
  instance_type = {
    x86_64 = "t3a.micro"
    arm64  = "t4g.micro"
  }
  ami_filters = {
    # https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html
    al2023 = "al2023-ami-2023.*"
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

variable "ami" {
  type    = string
  default = ""
}

variable "os" {
  type    = string
  default = "al2023"
}

variable "disk_size" {
  type    = number
  default = 16 # in GiB
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

variable "public" {
  type    = bool
  default = false
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
