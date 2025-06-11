# AMI Lookup Module - Shared by EC2 and ASG modules

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "main" {
  #executable_users = ["self"]
  most_recent = true
  #name_regex       = "^name"
  owners = [local.owners[var.os]]

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

  filter {
    name   = "state"
    values = ["available"]
  }

}
