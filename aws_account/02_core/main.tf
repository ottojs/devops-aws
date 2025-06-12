
# Import the main key and logging bucket from Step 1 to use it here
data "aws_kms_key" "main" {
  key_id = "alias/main"
}
data "aws_s3_bucket" "logging" {
  bucket = "devops-log-bucket-${var.random_id}"
}

# Main Notification Topic
# This is needed to send alerts for overall account health
module "sns" {
  source  = "../../modules/sns"
  name    = "devops"
  email   = var.email
  kms_key = data.aws_kms_key.main
  tags    = var.tags
}

# Once per account
module "security_global" {
  source        = "../../modules/security_global"
  sns_topic_arn = module.sns.topic_arn
  tags          = var.tags
}

# Allows SSM Connection (WebShell)
# Also contains EC2 Bastion role (ec2-ssm)
# Consider adding VPC Endpoints for extra protection
module "ssm" {
  source             = "../../modules/ssm"
  log_bucket         = data.aws_s3_bucket.logging
  log_retention_days = var.log_retention_days
  tags               = var.tags
}

# # WARNING: For production, set cost_savings to false or remove it
# module "security" {
#   source       = "../../modules/security"
#   cost_savings = true
#   random_id    = var.random_id
#   kms_key      = data.aws_kms_key.main
#   tags         = var.tags
# }

module "route53" {
  source      = "../../modules/route53_root"
  vpc         = module.myvpc.vpc
  root_domain = var.root_domain
  tags        = var.tags
}

# module "ses" {
#   source      = "../../modules/ses"
#   root_domain = module.route53.domain
#   depends_on  = [module.route53]
# }

# module "sqs" {
#   source  = "../../modules/sqs"
#   name    = "devops"
#   kms_key = data.aws_kms_key.main
#   tags    = var.tags
# }

# Create the VPC with:
# - public and private subnets
# - NAT gateway, Internet gateway, Network ACLs
# - empty default security group
# - "main" security group as a starting point (HTTP, HTTPS, SSH)
# - VPC flow logs in CloudWatch
module "myvpc" {
  source             = "../../modules/vpc"
  name               = "main"
  region             = data.aws_region.current.region
  kms_key            = data.aws_kms_key.main
  cidr               = "10.2.0.0/16"
  log_bucket         = data.aws_s3_bucket.logging
  log_retention_days = var.log_retention_days
  enable_igw         = true
  enable_nat         = true
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
  tags = var.tags
  # Warning: Disabling Dev Mode will be costly
  dev_mode = true
}

# # External Load Balancer (Public)
# module "alb_public" {
#   source             = "../../modules/load_balancer"
#   name               = "alb-public" # Keep this name
#   public             = true
#   vpc                = module.myvpc.vpc
#   subnets            = module.myvpc.subnets_public
#   root_domain        = module.route53.domain
#   log_bucket         = data.aws_s3_bucket.logging
#   log_retention_days = var.log_retention_days
#   kms_key            = data.aws_kms_key.main
#   sns_topic_arn      = module.sns.topic_arn
#   tags               = var.tags
#   depends_on         = [module.route53]
# }

# # Internal Load Balancer (Private)
# module "alb_private" {
#   source             = "../../modules/load_balancer"
#   name               = "alb-private" # Keep this name
#   public             = false
#   vpc                = module.myvpc.vpc
#   subnets            = module.myvpc.subnets_private
#   root_domain        = module.route53.domain
#   log_bucket         = data.aws_s3_bucket.logging
#   log_retention_days = var.log_retention_days
#   kms_key            = data.aws_kms_key.main
#   sns_topic_arn      = module.sns.topic_arn
#   tags               = var.tags
#   depends_on         = [module.route53]
# }

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

###################
##### FARGATE #####
###################

# module "ecs_cluster_fargate" {
#   source             = "../../modules/ecs_cluster"
#   name               = "ecs-cluster-fargate"
#   type               = "FARGATE"
#   kms_key            = data.aws_kms_key.main
#   log_retention_days = var.log_retention_days
#   tags               = var.tags
# }

###########################
##### EC2 SELF-HOSTED #####
###########################

# # WARNING: You want to underestimate the autoscaling CPU threshold
# # We want this to scale at 80% but put in 60% due to reporting challenges
# # Even when CPU was pinned at 100% in the OS, only 80% was reported
# # We may consider an alternative monitoring solution in the future
# module "asg_ec2" {
#   source               = "../../modules/asg"
#   name                 = "ecs-x86_64"
#   subnets              = module.myvpc.subnets_private
#   security_groups      = [module.myvpc.security_group.id]
#   iam_instance_profile = module.ssm.instance_profile
#   instance_type        = "t3a.small"
#   scale_up_cpu         = 60
#   count_min            = 1
#   count_max            = 3
#   kms_key              = data.aws_kms_key.main
#   sns_topic_arn        = module.sns.topic_arn
#   dev_mode             = true
#   tags                 = var.tags
#   # RHEL Example
#   os            = "al2023"
#   userdata_file = file("../../userdata/rhel.sh")
#   #
#   # # ECS Bottlerocket Example
#   # os = "bottlerocket_ecs"
#   # userdata_file = templatefile("../../userdata/ecs_bottlerocket.sh.tpl", {
#   #   cluster_name = module.ecs_cluster_ec2.cluster_name
#   # })
# }

# module "ecs_cluster_ec2" {
#   source             = "../../modules/ecs_cluster"
#   name               = "ecs-cluster-ec2"
#   type               = "EC2"
#   asg                = module.asg_ec2.asg
#   kms_key            = data.aws_kms_key.main
#   log_retention_days = var.log_retention_days
#   tags               = var.tags
# }
