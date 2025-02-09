
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "rds-${aws_db_instance.default.identifier}-CPUHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60 # Percent
  statistic           = "Average"
  threshold           = var.alert_cpu
  actions_enabled     = true
  alarm_actions       = [data.aws_sns_topic.devops.arn]
  ok_actions          = [data.aws_sns_topic.devops.arn]
  alarm_description   = "RDS CPU High"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.default.identifier
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "rds-${aws_db_instance.default.identifier}-MemoryLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = (var.alert_memory * local.mb) # in bytes
  actions_enabled     = true
  alarm_actions       = [data.aws_sns_topic.devops.arn]
  ok_actions          = [data.aws_sns_topic.devops.arn]
  alarm_description   = "RDS Memory Low"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.default.identifier
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "disk_space_low" {
  alarm_name          = "rds-${aws_db_instance.default.identifier}-DiskSpaceLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = (var.alert_disk_space * local.gb) # in bytes
  actions_enabled     = true
  alarm_actions       = [data.aws_sns_topic.devops.arn]
  ok_actions          = [data.aws_sns_topic.devops.arn]
  alarm_description   = "RDS Disk Low"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.default.identifier
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "write_iops_high" {
  alarm_name          = "rds-${aws_db_instance.default.identifier}-DiskWriteIOPSHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = 60 # Seconds
  statistic           = "Average"
  threshold           = var.alert_write_iops
  actions_enabled     = true
  alarm_actions       = [data.aws_sns_topic.devops.arn]
  ok_actions          = [data.aws_sns_topic.devops.arn]
  alarm_description   = "RDS Disk IOPS Write High"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.default.identifier
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "read_iops_high" {
  alarm_name          = "rds-${aws_db_instance.default.identifier}-DiskReadIOPSHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = 60 # Seconds
  statistic           = "Average"
  threshold           = var.alert_read_iops
  actions_enabled     = true
  alarm_actions       = [data.aws_sns_topic.devops.arn]
  ok_actions          = [data.aws_sns_topic.devops.arn]
  alarm_description   = "RDS Disk IOPS Read High"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.default.identifier
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
