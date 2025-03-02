
# PostgreSQL Database
module "db_postgresql" {
  source           = "../../modules/db_postgresql"
  name             = "my-postgresql-17"
  vpc              = data.aws_vpc.main
  subnet_ids       = data.aws_subnets.private.ids
  root_domain      = var.root_domain
  kms_key          = data.aws_kms_key.main
  admin_username   = "customadmin"
  db_name          = "myapp"
  backup_days      = 30
  alert_cpu        = 60  # Percent
  alert_memory     = 256 # MB
  alert_disk_space = 5   # GB
  alert_write_iops = 20
  alert_read_iops  = 100
  tags             = var.tags
}

# Valkey - Redis Alternative
module "db_valkey" {
  source     = "../../modules/db_valkey"
  name       = "my-valkey-8"
  vpc        = data.aws_vpc.main
  subnet_ids = data.aws_subnets.private.ids
  kms_key    = data.aws_kms_key.main
  password   = var.valkey_password
  tags       = var.tags
}

# OpenSearch - ElasticSearch Alternative
module "db_opensearch" {
  source      = "../../modules/opensearch"
  name        = "my-search"
  password    = var.opensearch_password
  vpc         = data.aws_vpc.main
  subnet_ids  = data.aws_subnets.private.ids
  root_domain = var.root_domain
  node_count  = 1
  node_size   = "t3.small.search"
  disk_size   = 20 # in GB
  tags        = var.tags
}

### API SERVER - FARGATE ###
# Your service MUST listen on port 8080
module "ecs_fargate_api_server" {
  source      = "../../modules/ecs_service"
  mode        = "server"
  type        = "FARGATE"
  name        = "api-server-fargate"
  tag         = "0.0.1"
  arch        = "X86_64" # ARM64
  ecs_cluster = "ecs-cluster-fargate"
  vpc         = data.aws_vpc.main
  subnet_ids  = data.aws_subnets.private.ids
  kms_key     = data.aws_kms_key.main
  envvars = {
    NODE_ENV = "production"
  }
  secrets = {
    # Secrets Manager Key
    # apps/APPNAME/SECRETNAME
    # so in this case...
    # apps/api-server-fargate/MY_SECRET
    MY_SECRET = "MY_SECRET"
  }
  tags = var.tags
  ### Server Only ###
  public      = true
  root_domain = var.root_domain
  priority    = 1
}

### API CRON JOB - FARGATE ###
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html
module "ecs_fargate_api_cron" {
  source      = "../../modules/ecs_service"
  mode        = "cron"
  type        = "FARGATE"
  name        = "api-cron-fargate"
  tag         = "0.0.1"
  arch        = "X86_64" # ARM64
  ecs_cluster = "ecs-cluster-fargate"
  vpc         = data.aws_vpc.main
  subnet_ids  = data.aws_subnets.private.ids
  kms_key     = data.aws_kms_key.main
  envvars = {
    NODE_ENV = "production"
  }
  secrets = {
    # Secrets Manager Key
    # apps/APPNAME/SECRETNAME
    # so in this case...
    # apps/api-cron-fargate/MY_SECRET
    MY_SECRET = "MY_SECRET"
  }
  tags = var.tags
  ### Cron Job Only ###
  timezone = "US/Eastern"
  schedule = "cron(0 * * * ? *)" # Every hour
  # TODO: Possible bug, need this for now
  root_domain = var.root_domain
}

### API SERVER - EC2 ###
# Your service MUST listen on port 8080
module "ecs_ec2_api_server" {
  source      = "../../modules/ecs_service"
  mode        = "server"
  type        = "EC2"
  name        = "api-server-ec2"
  tag         = "0.0.1"
  arch        = "X86_64" # ARM64
  ecs_cluster = "ecs-cluster-ec2"
  vpc         = data.aws_vpc.main
  subnet_ids  = data.aws_subnets.private.ids
  kms_key     = data.aws_kms_key.main
  envvars = {
    NODE_ENV = "production"
  }
  secrets = {
    # Secrets Manager Key
    # apps/APPNAME/SECRETNAME
    # so in this case...
    # apps/api-server-ec2/MY_SECRET
    MY_SECRET = "MY_SECRET"
  }
  tags = var.tags
  ### Server Only ###
  public      = true
  root_domain = var.root_domain
  priority    = 2
}
