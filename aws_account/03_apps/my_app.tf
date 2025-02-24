
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

# Your service MUST listen on port 8080
module "ecs_fargate_api" {
  source        = "../../modules/ecs_service"
  type          = "FARGATE"
  public        = true
  name          = "api-fargate"
  priority      = 1
  tag           = "0.0.1"
  arch          = "X86_64" # ARM64
  ecs_cluster   = "ecs-cluster-fargate"
  vpc           = data.aws_vpc.main
  subnet_ids    = data.aws_subnets.private.ids
  kms_key       = data.aws_kms_key.main
  root_domain   = var.root_domain
  load_balancer = data.aws_lb.public
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
}
