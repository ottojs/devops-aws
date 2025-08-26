
# DB Cluster Parameter Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group
resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "aurora-mysql-${var.name}"
  family      = "aurora-mysql${local.major_engine_version}"
  description = "Aurora MySQL cluster parameter group for ${var.name}"

  # Security and stability parameters
  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "general_log"
    value        = "0" # Disabled due to high volume
    apply_method = "immediate"
  }

  parameter {
    name         = "log_output"
    value        = "FILE"
    apply_method = "pending-reboot"
  }

  # Aurora MySQL audit logging - always enabled for security/compliance
  parameter {
    name         = "server_audit_logging"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "server_audit_events"
    value        = "CONNECT,QUERY_DCL,QUERY_DDL"
    apply_method = "immediate"
  }

  # Binary logging for point-in-time recovery and replication
  parameter {
    name         = "binlog_format"
    value        = "MIXED" # Best balance of safety and performance
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "binlog_checksum"
    value        = "CRC32" # Data integrity for binary logs
    apply_method = "immediate"
  }

  # Security: Force SSL/TLS connections (always enabled)
  parameter {
    name         = "require_secure_transport"
    value        = "ON"
    apply_method = "immediate"
  }

  tags = var.tags
}

# DB Parameter Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_db_parameter_group" "aurora" {
  name        = "aurora-mysql-${var.name}"
  family      = "aurora-mysql${local.major_engine_version}"
  description = "Aurora MySQL instance parameter group for ${var.name}"

  # Performance and stability parameters

  # Note: Aurora automatically calculates max_connections based on instance class memory

  # Note: innodb_flush_log_at_trx_commit is managed by Aurora and cannot be modified
  # Aurora automatically optimizes this for performance and durability

  # Note: thread_pool_size is automatically managed by Aurora based on instance vCPU count
  # This provides optimal performance without manual tuning

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "long_query_time"
    value        = "2" # Reasonable default for most applications
    apply_method = "immediate"
  }

  parameter {
    name         = "log_queries_not_using_indexes"
    value        = "1" # Log queries that don't use indexes
    apply_method = "immediate"
  }

  tags = var.tags
}
