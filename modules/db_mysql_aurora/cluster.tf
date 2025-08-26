# Aurora MySQL Module
# Configurable instances (single or multi-reader) with dev_mode cost optimization

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version
data "aws_secretsmanager_secret_version" "secret_password" {
  secret_id = var.admin_password
}

# Locals for production-grade overrides
locals {
  major_engine_version = join(".", slice(split(".", var.engine_version), 0, 2))

  # Cost optimizations for dev mode:
  deletion_protection          = !var.dev_mode                                       # Protection in prod only
  backup_retention_period      = var.dev_mode ? 7 : var.backup_retention_period_days # Reduce backup storage in dev
  enhanced_monitoring_interval = var.dev_mode ? 0 : 60                               # Enhanced monitoring costs extra
  skip_final_snapshot          = var.dev_mode                                        # No final snapshot in dev
  backtrack_window             = var.dev_mode ? 0 : var.backtrack_window_hours       # Backtrack has storage cost
  log_retention_days           = var.dev_mode ? 7 : var.log_retention_days           # Shorter retention in dev
}

# DB Subnet Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-mysql-${var.name}"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "aurora-mysql-${var.name}"
    },
    var.enable_aws_backup ? {
      "aws-backup:backup-plan" = var.backup_plan_name
      "Backup"                 = "true"
    } : {}
  )
}

# RDS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "aurora_mysql" {
  cluster_identifier = "aurora-mysql-${var.name}"
  engine             = "aurora-mysql"
  engine_mode        = "provisioned"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.admin_username
  master_password    = data.aws_secretsmanager_secret_version.secret_password.secret_string

  # Encryption
  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  # Backup
  backup_retention_period      = local.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  copy_tags_to_snapshot        = true
  backtrack_window             = local.backtrack_window

  # Security
  vpc_security_group_ids              = [aws_security_group.aurora.id]
  db_subnet_group_name                = aws_db_subnet_group.aurora.name
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.aurora.name
  iam_database_authentication_enabled = true

  # High Availability
  # Only set availability_zones if explicitly provided to avoid replacement
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : null

  # Monitoring
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]

  # Protection
  deletion_protection = local.deletion_protection
  skip_final_snapshot = local.skip_final_snapshot
  # ${formatdate("YYYY-MM-DD-hhmm", timestamp())}
  # Final snapshot identifier uses a static name that will be overwritten on each destroy
  final_snapshot_identifier = local.skip_final_snapshot ? null : "aurora-mysql-${var.name}-final-snapshot"


  tags = merge(
    var.tags,
    {
      Name = "aurora-mysql-${var.name}"
    },
    var.enable_aws_backup ? {
      "aws-backup:backup-plan" = var.backup_plan_name
      "Backup"                 = "true"
    } : {}
  )

  lifecycle {
    ignore_changes = [master_password]
  }
}
