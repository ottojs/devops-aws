
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2" {
  count         = 1
  ami           = var.ami == "" ? local.os[var.os][var.arch][data.aws_region.current.name] : var.ami
  instance_type = var.machine == "" ? local.instance_type[var.arch] : var.machine
  # TODO: Random Pick
  availability_zone           = "${data.aws_region.current.name}${element(var.azs, 0)}"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.public
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
    volume_size           = var.disk_size
    volume_type           = "gp3"
    tags = merge(var.tags, {
      Name = "${local.name}-disk"
    })
  }
  vpc_security_group_ids      = var.security_groups
  user_data                   = filebase64(var.userdata)
  user_data_replace_on_change = true

  # TODO: null does not clear
  iam_instance_profile = var.iam_instance_profile.name

  tags = merge(var.tags, {
    Name = local.name
  })
}
