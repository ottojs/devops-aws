
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
