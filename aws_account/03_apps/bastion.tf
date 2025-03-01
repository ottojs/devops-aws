# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group
data "aws_security_group" "main" {
  name = "main"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile
data "aws_iam_instance_profile" "ec2" {
  name = "tf-EC2-Instance-Profile"
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based, x86_64)
module "bastion_x86_64" {
  source               = "../../modules/ec2"
  name                 = "bastion"
  subnet_id            = data.aws_subnets.private.ids[0]
  os                   = "al2023"
  arch                 = "x86_64"
  machine              = "t3.small"
  security_groups      = [data.aws_security_group.main.id]
  iam_instance_profile = data.aws_iam_instance_profile.ec2
  userdata             = "../../userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based, ARM64)
module "bastion_arm64" {
  source               = "../../modules/ec2"
  name                 = "bastion"
  subnet_id            = data.aws_subnets.private.ids[0]
  os                   = "al2023"
  arch                 = "arm64"
  machine              = "t4g.small"
  security_groups      = [data.aws_security_group.main.id]
  iam_instance_profile = data.aws_iam_instance_profile.ec2
  userdata             = "../../userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}
