# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group
data "aws_security_group" "main" {
  name   = "main"
  vpc_id = data.aws_vpc.main.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile
data "aws_iam_instance_profile" "ec2" {
  name = "ec2-ssm-profile"
}

# === Important Notes ===
#
# You may delete or comment any machines you don't want to use
#
# EC2 Machine - Amazon Linux 2023 (RedHat-based, x86_64)
# If you don't want the underlying os to rebuild you
# need to pin the AMI version with the following:
# ami = "ami-xxxxxxxxxxxxxxxxx"
#
# If you need to attach an SSH Key (not recommended, except for debugging)
# Then add the following line:
# ssh_key = "name-of-key"

#############################
##### Amazon Linux 2023 #####
#############################

# # Bastion - AL2023 x86_64
# module "bastion_al2023_x86_64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "al2023"
#   arch                 = "x86_64"
#   machine              = "t3a.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/rhel.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }

# # Bastion - AL2023 ARM64
# module "bastion_al2023_arm64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "al2023"
#   arch                 = "arm64"
#   machine              = "t4g.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/rhel.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }

############################
##### Debian 13 Trixie #####
############################
# Coming Soon

##############################
##### Debian 12 Bookworm #####
##############################

# # Bastion - Debian 12 Bookworm x86_64
# module "bastion_debian12_x86_64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "debian12"
#   arch                 = "x86_64"
#   machine              = "t3a.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/debian.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }

# # Bastion - Debian 12 Bookworm ARM64
# module "bastion_debian12_arm642" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "debian12"
#   arch                 = "arm64"
#   machine              = "t4g.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/debian.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
#   disk_size            = 80
# }

##############################
##### Debian 11 Bullseye #####
##############################

# # Bastion - Debian 11 Bullseye x86_64
# module "bastion_debian11_x86_64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "debian11"
#   arch                 = "x86_64"
#   machine              = "t3a.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/debian.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }

# # Bastion - Debian 11 Bullseye ARM64
# module "bastion_debian11_x86_64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "debian11"
#   arch                 = "arm64"
#   machine              = "t4g.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/debian.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }

###################
##### Rocky 9 #####
###################

# # Bastion - Rocky Linux 9 x86_64
# module "bastion_rocky9_x86_64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "rocky9"
#   arch                 = "x86_64"
#   machine              = "t3a.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/rhel.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }

# # Bastion - Rocky Linux ARM64
# module "bastion_rocky9_arm64" {
#   source               = "../../modules/ec2"
#   name                 = "bastion"
#   subnet_id            = data.aws_subnets.private.ids[0]
#   os                   = "rocky9"
#   arch                 = "arm64"
#   machine              = "t4g.small"
#   security_groups      = [data.aws_security_group.main.id]
#   iam_instance_profile = data.aws_iam_instance_profile.ec2
#   userdata             = "../../userdata/rhel.sh"
#   kms_key              = data.aws_kms_key.main
#   tags                 = var.tags
# }
