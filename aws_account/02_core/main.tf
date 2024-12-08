
# Import the main key and logging bucket from Step 1 to use it here
data "aws_kms_key" "main" {
  key_id = "alias/main"
}
data "aws_s3_bucket" "logging" {
  bucket = "devops-log-bucket-${var.random_id}"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
resource "aws_sns_topic" "devops" {
  name              = "devops"
  display_name      = "devops"
  kms_master_key_id = data.aws_kms_key.main.id
  fifo_topic        = false # FIFO cannot deliver to email, sms, https
  signature_version = 2
  tags = {
    Name = "devops"
    App  = var.tag_app
  }
}

# Create the VPC with:
# - public and private subnets
# - NAT gateway, Internet gateway, Network ACLs
# - empty default security group
# - "main" security group as a starting point (HTTP, HTTPS, SSH)
# - VPC flow logs in CloudWatch
module "vpc_ohio" {
  source        = "../../modules/vpc"
  name          = "ohio"
  region        = data.aws_region.current.name
  kms_key       = data.aws_kms_key.main
  cidr          = "10.2.0.0/16"
  allowed_cidrs = var.allowed_cidrs
  log_bucket    = data.aws_s3_bucket.logging
  subnets_public = [
    {
      name = "main"
      az   = "a"
      cidr = "10.2.1.0/24"
    },
    {
      name = "main"
      az   = "b"
      cidr = "10.2.2.0/24"
    },
    {
      name = "main"
      az   = "c"
      cidr = "10.2.3.0/24"
    }
  ]
  subnets_private = [
    {
      name = "main"
      az   = "a"
      cidr = "10.2.11.0/24"
    },
    {
      name = "main"
      az   = "b"
      cidr = "10.2.12.0/24"
    },
    {
      name = "main"
      az   = "c"
      cidr = "10.2.13.0/24"
    },
    # {
    #   name = "vpn"
    #   az   = "a"
    #   cidr = "10.2.99.0/24"
    # }
  ]
  tag_app = var.tag_app
}

# Setting up a VPN has a fairly high cost
# You probably don't need it and if you do, it can be enabled temporarily
# See the README.md file for more instructions
#
# module "vpn" {
#   source        = "../../modules/vpn"
#   name          = "remote"
#   cidr          = "10.99.0.0/16"
#   file_key      = "key.pem"
#   file_crt      = "cert.pem"
#   kms_key       = data.aws_kms_key.main
#   subnet        = module.vpc_ohio.subnets_private[3] # "vpn" subnet
#   vpc           = module.vpc_ohio.vpc
#   allowed_cidrs = var.allowed_cidrs
#   tag_app       = var.tag_app
# }

# EC2 Machine - Amazon Linux 2023 (RedHat-based)
module "ec2_machine_al2023" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine"
  region               = data.aws_region.current.name
  access               = "private"
  subnet_id            = module.vpc_ohio.subnets_private[0].id
  os                   = "al2023_241111"
  arch                 = "arm64"
  machine              = "t4g.medium"
  ssh_key              = aws_key_pair.main.key_name
  security_groups      = [module.vpc_ohio.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_session_manager
  userdata             = "userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tag_app              = var.tag_app
}
