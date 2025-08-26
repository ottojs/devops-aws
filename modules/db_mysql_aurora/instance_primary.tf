
# Single Primary Instance (no read replicas)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "primary" {
  identifier                 = "aurora-mysql-${var.name}"
  cluster_identifier         = aws_rds_cluster.aurora_mysql.id
  instance_class             = "db.${var.instance_class}"
  engine                     = "aurora-mysql"
  engine_version             = var.engine_version
  db_parameter_group_name    = aws_db_parameter_group.aurora.name
  publicly_accessible        = false
  auto_minor_version_upgrade = false

  # Monitoring
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_id
  performance_insights_retention_period = 7 # Free tier
  monitoring_interval                   = local.enhanced_monitoring_interval
  monitoring_role_arn                   = local.enhanced_monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null

  tags = merge(var.tags, {
    Name = "aurora-mysql-${var.name}"
  })

  depends_on = [
    aws_rds_cluster.aurora_mysql
  ]
}
