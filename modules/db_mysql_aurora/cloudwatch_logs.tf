
# CloudWatch Log Groups and Retention Configuration
# Aurora creates log groups automatically when log exports are enabled
# We only manage retention settings on existing log groups created by RDS

locals {
  # Log types that will be exported (hardcoded list)
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]

  # Map of log types that will be exported
  log_group_names = {
    for log_type in local.enabled_cloudwatch_logs_exports :
    log_type => "/aws/rds/cluster/aurora-mysql-${var.name}/${log_type}"
  }

  # Use same retention for all log types
  # In dev mode, all logs retain for 7 days only
  log_retention_map = {
    audit     = local.log_retention_days
    error     = local.log_retention_days
    slowquery = local.log_retention_days
    general   = local.log_retention_days
  }
}
