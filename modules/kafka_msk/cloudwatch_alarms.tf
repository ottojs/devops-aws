# CloudWatch Alarms for MSK Kafka Cluster

# Critical - High CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "msk-${var.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CpuUser"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80 # percent
  alarm_description   = "MSK broker CPU utilization is too high"
  treat_missing_data  = "breaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-cpu-high"
  })
}

# Critical - Disk Usage Alarm
resource "aws_cloudwatch_metric_alarm" "disk_usage_critical" {
  alarm_name          = "msk-${var.name}-disk-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "KafkaBrokerStorageUtilization"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 85 # percent
  alarm_description   = "MSK broker disk usage is critically high"
  treat_missing_data  = "breaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-disk-critical"
  })
}

# Critical - Disk Usage Warning Alarm
resource "aws_cloudwatch_metric_alarm" "disk_usage_warning" {
  alarm_name          = "msk-${var.name}-disk-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "KafkaBrokerStorageUtilization"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 75 # percent
  alarm_description   = "MSK broker disk usage is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-disk-warning"
  })
}

# Critical - Memory Usage Alarm
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "msk-${var.name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MemoryUsed"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80 # percent
  alarm_description   = "MSK broker memory usage is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-memory-high"
  })
}

# Performance - High Network Input (DDoS or misconfiguration)
resource "aws_cloudwatch_metric_alarm" "network_in_high" {
  alarm_name          = "msk-${var.name}-network-in-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "NetworkRxPackets"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000 # 1M packets/sec
  alarm_description   = "MSK network input is unusually high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-network-in-high"
  })
}

# Performance -  Under-Replicated Partitions
resource "aws_cloudwatch_metric_alarm" "under_replicated_partitions" {
  alarm_name          = "msk-${var.name}-under-replicated"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnderReplicatedPartitions"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "MSK has under-replicated partitions"
  treat_missing_data  = "notBreaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-under-replicated"
  })
}

# Critical - Offline Partitions Count
resource "aws_cloudwatch_metric_alarm" "offline_partitions" {
  alarm_name          = "msk-${var.name}-offline-partitions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "OfflinePartitionsCount"
  namespace           = "AWS/Kafka"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "MSK has offline partitions - CRITICAL"
  treat_missing_data  = "breaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-offline-partitions"
  })
}

# Performance - Active Controller Count (should always be 1)
resource "aws_cloudwatch_metric_alarm" "active_controller" {
  alarm_name          = "msk-${var.name}-controller-issue"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ActiveControllerCount"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "MSK cluster controller issue detected"
  treat_missing_data  = "breaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-controller-issue"
  })
}

# Performance - Consumer Lag Monitoring (if topics are known)
resource "aws_cloudwatch_metric_alarm" "consumer_lag" {
  for_each = var.monitored_consumer_groups

  alarm_name          = "msk-${var.name}-lag-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MaxOffsetLag"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Maximum"
  threshold           = each.value.lag_threshold
  alarm_description   = "Consumer group ${each.key} lag is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    "Cluster Name"   = aws_msk_cluster.main.cluster_name
    "Consumer Group" = each.key
    "Topic"          = each.value.topic
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-lag-${each.key}"
  })
}

# Performance - Connection Count Alarm (detect connection leaks or attacks)
resource "aws_cloudwatch_metric_alarm" "connection_count_high" {
  alarm_name          = "msk-${var.name}-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ConnectionCount"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 1000 # 1000 connections
  alarm_description   = "MSK connection count is unusually high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-connections-high"
  })
}

# Performance -  Request Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "request_errors" {
  alarm_name          = "msk-${var.name}-request-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3

  metric_query {
    id          = "error_rate"
    expression  = "(m1/m2)*100"
    label       = "Error Rate"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "RequestErrorCount"
      namespace   = "AWS/Kafka"
      period      = 300
      stat        = "Sum"
      dimensions = {
        "Cluster Name" = aws_msk_cluster.main.cluster_name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/Kafka"
      period      = 300
      stat        = "Sum"
      dimensions = {
        "Cluster Name" = aws_msk_cluster.main.cluster_name
      }
    }
  }

  threshold          = 5 # percent
  alarm_description  = "MSK request error rate is high"
  treat_missing_data = "notBreaching"

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "msk-${var.name}-request-errors"
  })
}
