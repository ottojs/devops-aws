
module "kms_main" {
  source      = "./modules/kms_key_region_symmetric"
  name        = "main"
  description = "Main Customer-Managed Key"
  iam_user    = var.iam_user
  tag_app     = "CORE"
}

module "log_bucket" {
  source              = "./modules/bucket_private"
  name                = "log-bucket"
  random_id           = var.random_id
  kms_key             = module.kms_main.key
  log_bucket_id       = "none"
  log_bucket_disabled = true
  tag_app             = "CORE"
}

module "vpc_ohio" {
  source        = "./modules/vpc"
  name          = "ohio"
  region        = "us-east-2"
  kms_key       = module.kms_main.key
  cidr          = "10.2.0.0/16"
  allowed_cidrs = var.allowed_cidrs
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
    {
      name = "vpn"
      az   = "a"
      cidr = "10.2.99.0/24"
    }
  ]
  tag_app = "CORE"
}

module "vpn" {
  source        = "./modules/vpn"
  name          = "remote"
  cidr          = "10.99.0.0/16"
  file_key      = "key.pem"
  file_crt      = "cert.pem"
  kms_key       = module.kms_main.key
  subnet        = module.vpc_ohio.subnets_private[3] # "vpn" subnet
  vpc           = module.vpc_ohio.vpc
  allowed_cidrs = var.allowed_cidrs
  tag_app       = "CORE"
}

module "ec2_machine_al2023" {
  source               = "./modules/ec2"
  name                 = "al2023-machine"
  region               = "us-east-2"
  access               = "private"
  subnet_id            = module.vpc_ohio.subnets_private[0].id
  os                   = "al2023_241111"
  arch                 = "arm64"
  machine              = "t4g.medium"
  ssh_key              = aws_key_pair.main.key_name
  security_groups      = [module.vpc_ohio.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_session_manager
  userdata             = "userdata/userdata_rhel.sh"
  kms_key              = module.kms_main.key
  tag_app              = "CORE"
}
