
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
  tags = merge(var.tags, {
    Name = "devops"
  })
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
  allowed_cidrs      = var.allowed_cidrs
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
  root_domain = var.root_domain
  log_bucket  = data.aws_s3_bucket.logging
  tags        = var.tags
}

# Internal Load Balancer (Private)
module "alb_private" {
  source      = "../../modules/load_balancer"
  name        = "alb-private"
  public      = false
  vpc         = module.myvpc.vpc
  subnets     = module.myvpc.subnets_private
  root_domain = var.root_domain
  log_bucket  = data.aws_s3_bucket.logging
  tags        = var.tags
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
#   allowed_cidrs = var.allowed_cidrs
#   tags       = var.tags
# }

# PostgreSQL Database
module "db_postgresql" {
  source         = "../../modules/db_postgresql"
  name           = "my-postgresql-17"
  vpc            = module.myvpc.vpc
  subnets        = module.myvpc.subnets_private
  kms_key        = data.aws_kms_key.main
  admin_username = "customadmin"
  db_name        = "myapp"
  tags           = var.tags
}

# Redis/ValKey In-Memory Cache
# WARNING: This is for testing only and will be replaced with ValKey v8.x soon
# For now, it's Redis v7.1.x
# More info: https://valkey.io/blog/valkey-8-ga/
module "db_valkey" {
  source    = "../../modules/db_valkey"
  name      = "my-redis-but-valkey-soon"
  passwords = ["letsusevalkeynow2024"]
  vpc       = module.myvpc.vpc
  subnets   = module.myvpc.subnets_private
  tags      = var.tags
}

# EC2 Machine - Amazon Linux 2023 (RedHat-based)
module "ec2_machine_al2023_x86_64" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine-x86_64"
  access               = "private"
  subnet_id            = module.myvpc.subnets_private[0].id
  os                   = "al2023_250128"
  arch                 = "x86_64"
  machine              = "t3.small"
  ssh_key              = aws_key_pair.main.key_name
  security_groups      = [module.myvpc.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2
  userdata             = "userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}
module "ec2_machine_al2023_arm64" {
  source               = "../../modules/ec2"
  name                 = "al2023-machine-arm64"
  access               = "private"
  subnet_id            = module.myvpc.subnets_private[0].id
  os                   = "al2023_250128"
  arch                 = "arm64"
  machine              = "t4g.small"
  ssh_key              = aws_key_pair.main.key_name
  security_groups      = [module.myvpc.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2
  userdata             = "userdata/userdata_rhel.sh"
  kms_key              = data.aws_kms_key.main
  tags                 = var.tags
}

###################
##### FARGATE #####
###################

module "ecs_cluster_fargate" {
  source             = "../../modules/ecs_cluster"
  name               = "tf-ecs-cluster-fargate"
  type               = "FARGATE"
  kms_key            = data.aws_kms_key.main
  log_retention_days = var.log_retention_days
  tags               = var.tags
}

module "ecs_service_api_fargate" {
  source        = "../../modules/ecs_service"
  type          = "FARGATE"
  public        = true
  name          = "api-fargate"
  priority      = 1
  tag           = "0.0.1"
  arch          = "X86_64" # ARM64
  ecs_cluster   = module.ecs_cluster_fargate.cluster
  vpc           = module.myvpc.vpc
  subnets       = module.myvpc.subnets_private
  kms_key       = data.aws_kms_key.main
  root_domain   = var.root_domain
  load_balancer = module.alb_public.load_balancer
  lb_listener   = module.alb_public.listener_https
  tags          = var.tags
}

### CRON JOB ###
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html
module "ecs_cron_fargate_example" {
  source      = "../../modules/ecs_cron"
  type        = "FARGATE"
  name        = "example"
  tag         = "0.0.1"
  arch        = "X86_64" # ARM64
  ecs_cluster = module.ecs_cluster_fargate.cluster
  vpc         = module.myvpc.vpc
  subnets     = module.myvpc.subnets_private
  kms_key     = data.aws_kms_key.main
  timezone    = "US/Eastern"
  schedule    = "cron(0 * * * ? *)" # Every hour
  tags        = var.tags
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
  name                 = "tf-asg-ecs-x86_64"
  subnets              = module.myvpc.subnets_private
  security_groups      = [module.myvpc.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2
  instance_type        = "t3.small"
  scale_up_cpu         = 60
  count_min            = 1
  count_max            = 2
  tags                 = var.tags
  # RHEL Example
  # al2023-ami-2023.6.20250128.0-kernel-6.1-x86_64  2025/01/28
  # ami           = "ami-018875e7376831abe"
  # userdata_file = file("./userdata/userdata_rhel.sh")
  #
  # ECS Bottlerocket Example
  # bottlerocket-aws-ecs-2-x86_64-v1.32.0-cacc4ce9  2025/01/27
  ami = "ami-06ca440d570381dfe"
  userdata_file = templatefile("userdata/userdata_ecs_bottlerocket.sh.tpl", {
    cluster_name = module.ecs_cluster_ec2.cluster.name
  })
}

module "ecs_cluster_ec2" {
  source             = "../../modules/ecs_cluster"
  name               = "tf-ecs-cluster-ec2"
  type               = "EC2"
  asg                = module.asg_ec2.asg
  kms_key            = data.aws_kms_key.main
  log_retention_days = var.log_retention_days
  tags               = var.tags
}

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
  root_domain   = var.root_domain
  load_balancer = module.alb_public.load_balancer
  lb_listener   = module.alb_public.listener_https
  tags          = var.tags
}

module "ses" {
  source      = "../../modules/ses"
  root_domain = var.root_domain
}

module "sqs" {
  source  = "../../modules/sqs"
  name    = "devops"
  kms_key = data.aws_kms_key.main
  tags    = var.tags
}
