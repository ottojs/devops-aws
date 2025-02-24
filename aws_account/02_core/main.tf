
# Import the main key and logging bucket from Step 1 to use it here
data "aws_kms_key" "main" {
  key_id = "alias/main"
}
data "aws_s3_bucket" "logging" {
  bucket = "devops-log-bucket-${var.random_id}"
}

module "sns" {
  source  = "../../modules/sns"
  name    = "devops"
  email   = var.email
  kms_key = data.aws_kms_key.main
  tags    = var.tags
}

module "route53" {
  source      = "../../modules/route53_root"
  vpc         = module.myvpc.vpc
  root_domain = var.root_domain
  tags        = var.tags
}

# Create the VPC with:
# - public and private subnets
# - NAT gateway, Internet gateway, Network ACLs
# - empty default security group
# - "main" security group as a starting point (HTTP, HTTPS, SSH)
# - VPC flow logs in CloudWatch
module "myvpc" {
  source             = "../../modules/vpc"
  name               = "main"
  region             = data.aws_region.current.name
  kms_key            = data.aws_kms_key.main
  cidr               = "10.2.0.0/16"
  log_bucket         = data.aws_s3_bucket.logging
  log_retention_days = var.log_retention_days
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
}

# External Load Balancer (Public)
module "alb_public" {
  source      = "../../modules/load_balancer"
  name        = "alb-public"
  public      = true
  vpc         = module.myvpc.vpc
  subnets     = module.myvpc.subnets_public
  root_domain = module.route53.domain
  log_bucket  = data.aws_s3_bucket.logging
  tags        = var.tags
  depends_on  = [module.route53]
}

# Internal Load Balancer (Private)
module "alb_private" {
  source      = "../../modules/load_balancer"
  name        = "alb-private"
  public      = false
  vpc         = module.myvpc.vpc
  subnets     = module.myvpc.subnets_private
  root_domain = module.route53.domain
  log_bucket  = data.aws_s3_bucket.logging
  tags        = var.tags
  depends_on  = [module.route53]
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
#   subnet        = module.myvpc.subnets_private[3] # "vpn" subnet
#   vpc           = module.myvpc.vpc
#   vpn_cidrs     = var.vpn_cidrs
#   tags          = var.tags
# }

# # Redis In-Memory Cache
# # WARNING: You should use Valkey instead
# # More info: https://valkey.io/blog/valkey-8-ga/
# module "db_redis" {
#   source    = "../../modules/db_redis"
#   name      = "my-redis"
#   passwords = ["letsusevalkeyinstead2025"]
#   vpc       = module.myvpc.vpc
#   subnets   = module.myvpc.subnets_private
#   tags      = var.tags
# }

# # Valkey password requirements
# # 16 to 128 alphanumeric characters or symbols (excluding @, ", and /)
# # https://www.random.org/strings/?num=5&len=16&digits=on&upperalpha=on&loweralpha=on&unique=on&format=html&rnd=new
# module "db_valkey" {
#   source   = "../../modules/db_valkey"
#   name     = "my-valkey"
#   vpc      = module.myvpc.vpc
#   subnets  = module.myvpc.subnets_public
#   kms_key  = data.aws_kms_key.main
#   password = "REPLACEME"
#   tags     = var.tags
# }

# EC2 Machine - Amazon Linux 2023 (RedHat-based)
module "ec2_machine_al2023_x86_64" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine-x86_64"
  access               = "private"
  subnet_id            = module.myvpc.subnets_private[0].id
  os                   = "al2023_250218"
  arch                 = "x86_64"
  machine              = "t3.small"
  security_groups      = [module.myvpc.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2
  userdata             = "../../userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}
module "ec2_machine_al2023_arm64" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine-arm64"
  access               = "private"
  subnet_id            = module.myvpc.subnets_private[0].id
  os                   = "al2023_250218"
  arch                 = "arm64"
  machine              = "t4g.small"
  security_groups      = [module.myvpc.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2
  userdata             = "../../userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}

###################
##### FARGATE #####
###################

module "ecs_cluster_fargate" {
  source             = "../../modules/ecs_cluster"
  name               = "ecs-cluster-fargate"
  type               = "FARGATE"
  kms_key            = data.aws_kms_key.main
  log_retention_days = var.log_retention_days
  tags               = var.tags
}

###########################
##### EC2 SELF-HOSTED #####
###########################

# WARNING: You want to underestimate the autoscaling CPU threshold
# We want this to scale at 80% but put in 60% due to reporting challenges
# Even when CPU was pinned at 100% in the OS, only 80% was reported
# We may consider an alternative monitoring solution in the future
module "asg_ec2" {
  source               = "../../modules/asg"
  name                 = "asg-ecs-x86_64"
  subnets              = module.myvpc.subnets_private
  security_groups      = [module.myvpc.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2
  instance_type        = "t3.small"
  scale_up_cpu         = 60
  count_min            = 1
  count_max            = 2
  tags                 = var.tags
  # RHEL Example
  # al2023-ami-2023.6.20250211.0-kernel-6.1-x86_64  2025/02/11
  # ami           = "ami-0604f27d956d83a4d"
  # userdata_file = file("../../userdata/userdata_rhel.sh")
  #
  # ECS Bottlerocket Example
  # bottlerocket-aws-ecs-2-x86_64-v1.32.0-cacc4ce9  2025/01/27
  ami = "ami-06ca440d570381dfe"
  userdata_file = templatefile("../../userdata/userdata_ecs_bottlerocket.sh.tpl", {
    cluster_name = module.ecs_cluster_ec2.cluster.name
  })
}

module "ecs_cluster_ec2" {
  source             = "../../modules/ecs_cluster"
  name               = "ecs-cluster-ec2"
  type               = "EC2"
  asg                = module.asg_ec2.asg
  kms_key            = data.aws_kms_key.main
  log_retention_days = var.log_retention_days
  tags               = var.tags
}

# Your service MUST listen on port 8080
module "ecs_service_api_ec2" {
  source        = "../../modules/ecs_service"
  type          = "EC2"
  public        = true
  name          = "api-ec2"
  priority      = 2
  tag           = "0.0.1"
  arch          = "X86_64" # ARM64
  ecs_cluster   = module.ecs_cluster_ec2.cluster
  vpc           = module.myvpc.vpc
  subnets       = module.myvpc.subnets_private
  kms_key       = data.aws_kms_key.main
  root_domain   = module.route53.domain
  load_balancer = module.alb_public.load_balancer
  lb_listener   = module.alb_public.listener_https
  envvars = {
    NODE_ENV = "production"
  }
  secrets = {}
  tags    = var.tags
  depends_on = [ module.route53 ]
}

module "ses" {
  source      = "../../modules/ses"
  root_domain = module.route53.domain
  depends_on  = [module.route53]
}

module "sqs" {
  source  = "../../modules/sqs"
  name    = "devops"
  kms_key = data.aws_kms_key.main
  tags    = var.tags
}
