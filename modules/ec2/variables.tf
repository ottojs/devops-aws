data "aws_region" "current" {}

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
# aws ec2 describe-images --owners amazon --filters "Name=architecture,Values=x86_64" --filters "Name=name,Values=al2023-ami-2023*"

# Amazon Linux 2023
# al2023-ami-2023.6.YYYYMMDD.2-kernel-6.1-x86_64
# al2023-ami-2023.6.YYYYMMDD.2-kernel-6.1-arm64

# RHEL 9
# RHEL-9.5.0_HVM-20250313-arm64-0-Hourly2-GP3
# RHEL-9.5.0_HVM-20250313-x86_64-0-Hourly2-GP3

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
    # https://aws.amazon.com/partners/redhat/
    rhel9 = "RHEL-9.5.0_HVM-*"
    # https://www.debian.org/releases/
    # We add "a" at the end to catch "amd64" and "arm64", and avoid "backports"
    debian           = "debian-12-a*"
    debian12         = "debian-12-a*"
    debian-12        = "debian-12-a*"
    debian-bookworm  = "debian-12-a*"
    debian-stable    = "debian-12-a*"
    debian11         = "debian-11-a*"
    debian-11        = "debian-11-a*"
    debian-bullseye  = "debian-11-a*"
    debian-oldstable = "debian-11-a*"
    # Rocky Linux
    # https://rockylinux.org/download
    # Rocky-9-EC2-Base-9.5-YYYYMMDD.0.x86_64
    # Rocky-9-EC2-LVM-9.5-YYYYMMDD.0.x86_64 (Preferred)
    rocky9 = "Rocky-9-EC2-LVM-9.5-*"
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
