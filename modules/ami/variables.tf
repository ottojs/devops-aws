# AMI Lookup Module Variables

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
# aws ec2 describe-images --owners amazon --filters "Name=architecture,Values=x86_64" --filters "Name=name,Values=al2023-ami-2023*"

# Amazon Linux 2023
# al2023-ami-2023.6.YYYYMMDD.2-kernel-6.1-x86_64
# al2023-ami-2023.6.YYYYMMDD.2-kernel-6.1-arm64

# RHEL 9
# RHEL-9.5.0_HVM-20250313-arm64-0-Hourly2-GP3
# RHEL-9.5.0_HVM-20250313-x86_64-0-Hourly2-GP3

locals {
  # https://aws.amazon.com/ec2/instance-types/t3/
  # https://aws.amazon.com/ec2/instance-types/t4/
  default_instance_type = {
    x86_64 = "t3a.micro"
    arm64  = "t4g.micro"
  }
  ami_filters = {
    # Bottlerocket
    bottlerocket_ecs          = "bottlerocket-aws-ecs-2-${var.arch}-*"
    bottlerocket_k8s_133      = "bottlerocket-aws-k8s-1.33-${var.arch}-*"
    bottlerocket_k8s_133_fips = "bottlerocket-aws-k8s-1.33-fips-${var.arch}-*"
    # https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html
    al2023 = "al2023-ami-2023.*"
    # https://aws.amazon.com/partners/redhat/
    rhel9 = "RHEL-9.5.0_HVM-*"
    # https://www.debian.org/releases/
    # We add "a" at the end to catch "amd64" and "arm64", and avoid "backports"
    debian           = "debian-12-a*"
    debian12         = "debian-12-a*"
    debian_12        = "debian-12-a*"
    debian_bookworm  = "debian-12-a*"
    debian_stable    = "debian-12-a*"
    debian11         = "debian-11-a*"
    debian_11        = "debian-11-a*"
    debian_bullseye  = "debian-11-a*"
    debian_oldstable = "debian-11-a*"
    # Rocky Linux
    # https://rockylinux.org/download
    # Rocky-9-EC2-Base-9.5-YYYYMMDD.0.x86_64
    # Rocky-9-EC2-LVM-9.5-YYYYMMDD.0.x86_64 (Preferred)
    rocky9 = "Rocky-9-EC2-LVM-9.5-*"
  }
}

variable "os" {
  type        = string
  default     = "al2023"
  description = "Operating system for the instance (al2023, rhel9, debian12, rocky9, etc.)"

  validation {
    condition     = contains(keys(local.ami_filters), var.os)
    error_message = "OS must be one of: ${join(", ", keys(local.ami_filters))}"
  }
}

variable "arch" {
  type        = string
  default     = "x86_64"
  description = "CPU architecture for the instance (x86_64 or arm64)"

  validation {
    condition     = contains(["x86_64", "arm64"], var.arch)
    error_message = "Architecture must be either x86_64 or arm64"
  }
}
