# === Welcome! ==
# Please uncomment the pieces you want to use
# Remember to enable the services (Load Balancers, ECS Clusters) in 02_main if you need them

# # PostgreSQL Database
# # Takes about 17 minutes to create
# # Takes about  7 minutes to destroy, may need multiple runs
# module "db_postgresql" {
#   source           = "../../modules/db_postgresql"
#   name             = "my-postgresql-17"
#   vpc              = data.aws_vpc.main
#   subnet_ids       = data.aws_subnets.private.ids
#   root_domain      = var.root_domain
#   kms_key          = data.aws_kms_key.main
#   admin_username   = "customadmin"
#   db_name          = "defaultdb"
#   backup_days      = 30
#   alert_cpu        = 60  # Percent
#   alert_memory     = 256 # MB
#   alert_disk_space = 5   # GB
#   alert_write_iops = 20
#   alert_read_iops  = 100
#   tags             = var.tags
# }

# # Valkey - Redis Fork/Alternative
# # Takes about 19 minutes to create
# # Takes about 9  minutes to destroy
# #
# # Password should be stored in Secrets Manager
# # Password Requirements: 16 to 128 alphanumeric characters or symbols (excluding @, ", and /)
# module "db_valkey" {
#   source      = "../../modules/db_valkey"
#   name        = "my-valkey-8"
#   vpc         = data.aws_vpc.main
#   subnet_ids  = data.aws_subnets.private.ids
#   root_domain = var.root_domain
#   kms_key     = data.aws_kms_key.main
#   password    = "db/valkey/password"
#   tags        = var.tags
# }

# # MySQL Aurora
# # Takes about 7  minutes to create
# # Takes about 11 minutes to destroy
# module "db_mysql_aurora" {
#   source             = "../../modules/db_mysql_aurora"
#   name               = "my-app"
#   vpc                = data.aws_vpc.main
#   kms_key_id         = data.aws_kms_key.main.arn
#   subnet_ids         = data.aws_subnets.private.ids
#   sns_topic          = data.aws_sns_topic.main
#   admin_username     = "customadmin"
#   admin_password     = "db/aurora-mysql/password"
#   log_retention_days = var.log_retention_days
#   dev_mode           = true
#   tags               = var.tags
#   #reader_instance_count = 1
# }

# # MariaDB
# # Takes about 18 minutes to create
# # Takes about  7 minutes to destroy, may need multiple runs
# module "db_mariadb" {
#   source           = "../../modules/db_mariadb"
#   name             = "my-mariadb-11"
#   vpc              = data.aws_vpc.main
#   subnet_ids       = data.aws_subnets.private.ids
#   root_domain      = var.root_domain
#   kms_key          = data.aws_kms_key.main
#   admin_username   = "customadmin"
#   db_name          = "defaultdb"
#   backup_days      = 30
#   alert_cpu        = 60  # Percent
#   alert_memory     = 256 # MB
#   alert_disk_space = 5   # GB
#   alert_write_iops = 20
#   alert_read_iops  = 100
#   tags             = var.tags
# }

# # OpenSearch - ElasticSearch Fork/Alternative
# # Takes about 18 minutes to create
# # Takes about 15 minutes to delete
# #
# # Password should be stored in Secrets Manager
# # Password must contain at least one:
# # - uppercase letter
# # - lowercase letter
# # - number
# # - special character
# module "db_opensearch" {
#   source      = "../../modules/opensearch"
#   name        = "my-search"
#   password    = "db/opensearch/password"
#   vpc         = data.aws_vpc.main
#   subnet_ids  = data.aws_subnets.private.ids
#   root_domain = var.root_domain
#   node_count  = 1
#   node_size   = "t3.small.search"
#   disk_size   = 20 # in GB
#   tags        = var.tags
# }
