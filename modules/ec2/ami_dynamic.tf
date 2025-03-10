
# Note: We only use owner alias "amazon" for safety purposes

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
# aws ec2 describe-images --owners amazon --filters "Name=architecture,Values=x86_64" --filters "Name=name,Values=al2023-ami-2023*"

# Amazon Linux 2023
# al2023-ami-2023.6.YYYYMMDD.2-kernel-6.1-x86_64
# al2023-ami-2023.6.YYYYMMDD.2-kernel-6.1-arm64

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "main" {
  #executable_users = ["self"]
  most_recent = true
  #name_regex       = "^name"
  owners = ["amazon"]

  filter {
    name   = "name"
    values = [local.ami_filters[var.os]]
  }

  filter {
    name   = "architecture"
    values = [var.arch]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
