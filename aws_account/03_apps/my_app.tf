
# PostgreSQL Database
module "db_postgresql" {
  source           = "../../modules/db_postgresql"
  name             = "my-postgresql-17"
  vpc              = data.aws_vpc.main
  subnet_ids       = data.aws_subnets.private.ids
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

# OpenSearch
module "opensearch" {
  source      = "../../modules/opensearch"
  name        = "mysearch"
  password    = var.opensearch_password
  vpc         = data.aws_vpc.main
  subnet_ids  = data.aws_subnets.private.ids
  root_domain = var.root_domain
  node_count  = 1
  node_size   = "t3.small.search"
  disk_size   = 20 # in GB
  tags        = var.tags
}

### SERVER ###
# Your service MUST listen on port 8080
module "ecs_fargate_api" {
  source      = "../../modules/ecs_service"
  mode        = "server"
  type        = "FARGATE"
  name        = "api-fargate"
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
    # apps/api-fargate/bingo
    THESECRET = "bingo"
  }
  tags = var.tags
  ### Server Only ###
  public      = true
  root_domain = var.root_domain
  priority    = 1
}

### CRON JOB ###
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html
module "ecs_fargate_cron" {
  source      = "../../modules/ecs_service"
  mode        = "server"
  type        = "FARGATE"
  name        = "cron-fargate"
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
    # apps/api-fargate/bingo
    THESECRET = "bingo"
  }
  tags = var.tags
  ### Cron Job Only ###
  timezone = "US/Eastern"
  schedule = "cron(0 * * * ? *)" # Every hour
  # Possible Bug, need this for now
  root_domain = var.root_domain
}
