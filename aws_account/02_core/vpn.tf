
# Setting up a VPN has a fairly high cost
# You probably don't need it and if you do, it can be enabled temporarily
# See the README.md file for more instructions
#
# module "vpn" {
#   source             = "../../modules/vpn"
#   name               = "remote"
#   cidr               = "10.99.0.0/16"
#   file_key           = "key.pem"
#   file_crt           = "cert.pem"
#   kms_key            = data.aws_kms_key.main
#   subnet             = module.myvpc.subnets_private[3] # "vpn" subnet
#   vpc                = module.myvpc.vpc
#   vpn_cidrs          = var.vpn_cidrs
#   log_retention_days = var.log_retention_days
#   tags               = var.tags
# }
