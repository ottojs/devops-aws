# AMI Lookup Module - Shared by EC2 and ASG modules

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "main" {
  #executable_users = ["self"]
  most_recent = true
  #name_regex       = "^name"
  # Note: We only use owner alias "amazon" for safety purposes
  # Amazon, Rocky (Account ID)
  # AlmaLinux (and more in Marketplace, not good) 679593333241
  owners = ["amazon", "792107900819"]

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
