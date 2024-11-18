
locals {
  # https://aws.amazon.com/ec2/instance-types/t4/
  instance_type = {
    x86_64 = "t3a.micro"
    arm64  = "t4g.micro"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2" {
  count         = 1
  ami           = local.os[var.os][var.arch][var.region]
  instance_type = var.machine == "" ? local.instance_type[var.arch] : var.machine
  # TODO: Random Pick
  availability_zone           = element(var.azs, 0)
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.access == "public"
  monitoring                  = false
  key_name                    = var.ssh_key

  # IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key.arn
    volume_size           = 16
    volume_type           = "gp3"
    tags = {
      Name = "${var.name}-disk"
      APP  = var.tag_app
    }
  }
  vpc_security_group_ids      = var.security_groups
  user_data                   = filebase64(var.userdata)
  user_data_replace_on_change = true

  # TODO: null does not clear
  iam_instance_profile = var.iam_instance_profile.name

  tags = {
    Name = var.name
    App  = var.tag_app
  }
}
