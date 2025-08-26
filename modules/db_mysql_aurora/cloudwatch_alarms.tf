
# CPU Utilization Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "aurora-mysql-${var.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold_high
  alarm_description   = "Aurora CPU utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}

# Database Connections Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "connections_high" {
  alarm_name          = "aurora-mysql-${var.name}-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connections_threshold_high
  alarm_description   = "Aurora database connections are too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}

# Freeable Memory Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "aurora-mysql-${var.name}-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold_low_bytes
  alarm_description   = "Aurora freeable memory is too low"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}

# Storage Space Alarm (for Aurora storage auto-scaling monitoring)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "storage_space_low" {
  alarm_name          = "aurora-mysql-${var.name}-storage-space-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeLocalStorage"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.storage_threshold_low_bytes
  alarm_description   = "Aurora free local storage is too low"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}

# Read Latency Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "read_latency_high" {
  alarm_name          = "aurora-mysql-${var.name}-read-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.read_latency_threshold_ms / 1000 # Convert to seconds
  alarm_description   = "Aurora read latency is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}

# Write Latency Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "write_latency_high" {
  alarm_name          = "aurora-mysql-${var.name}-write-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.write_latency_threshold_ms / 1000 # Convert to seconds
  alarm_description   = "Aurora write latency is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}

# Deadlock Alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "deadlocks" {
  alarm_name          = "aurora-mysql-${var.name}-deadlocks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Deadlocks"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.deadlock_threshold
  alarm_description   = "Aurora database has deadlocks"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_mysql.id
  }

  alarm_actions = [var.sns_topic.arn]

  tags = var.tags
}
