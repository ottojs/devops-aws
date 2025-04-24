# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group
data "aws_security_group" "main" {
  name = "main"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile
data "aws_iam_instance_profile" "ec2" {
  name = "ec2-ssm-profile"
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based, x86_64)
# If you don't want the underlying os to rebuild you
# need to pin the AMI version with the following:
# ami = "ami-xxxxxxxxxxxxxxxxx"
module "bastion_x86_64" {
  source               = "../../modules/ec2"
  name                 = "bastion"
  subnet_id            = data.aws_subnets.private.ids[0]
  os                   = "al2023"
  arch                 = "x86_64"
  machine              = "t3a.small"
  security_groups      = [data.aws_security_group.main.id]
  iam_instance_profile = data.aws_iam_instance_profile.ec2
  userdata             = "../../userdata/rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based, ARM64)
# If you don't want the underlying os to rebuild you
# need to pin the AMI version with the following:
# ami = "ami-xxxxxxxxxxxxxxxxx"
module "bastion_arm64" {
  source               = "../../modules/ec2"
  name                 = "bastion"
  subnet_id            = data.aws_subnets.private.ids[0]
  os                   = "al2023"
  arch                 = "arm64"
  machine              = "t4g.small"
  security_groups      = [data.aws_security_group.main.id]
  iam_instance_profile = data.aws_iam_instance_profile.ec2
  userdata             = "../../userdata/rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}
