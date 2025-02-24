# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group
data "aws_security_group" "main" {
  name = "main"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile
data "aws_iam_instance_profile" "ec2" {
  name = "tf-EC2-Instance-Profile"
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based, x86_64)
module "ec2_machine_al2023_x86_64" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine-x86_64"
  access               = "private"
  subnet_id            = data.aws_subnets.private.ids[0]
  os                   = "al2023_250218"
  arch                 = "x86_64"
  machine              = "t3.small"
  security_groups      = [data.aws_security_group.main.id]
  iam_instance_profile = data.aws_iam_instance_profile.ec2
  userdata             = "../../userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based, ARM64)
module "ec2_machine_al2023_arm64" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine-arm64"
  access               = "private"
  subnet_id            = data.aws_subnets.private.ids[0]
  os                   = "al2023_250218"
  arch                 = "arm64"
  machine              = "t4g.small"
  security_groups      = [data.aws_security_group.main.id]
  iam_instance_profile = data.aws_iam_instance_profile.ec2
  userdata             = "../../userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}
