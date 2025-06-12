# AWS Budget for CloudFront Cost Monitoring
# Helps detect unexpected traffic spikes through cost anomalies

# Budget for CloudFront Distribution Costs
resource "aws_budgets_budget" "cloudfront" {
  name         = "${var.name}-cloudfront-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_amount)
  limit_unit   = "USD"
  time_unit    = var.budget_time_unit

  # Filter to only track costs for this specific CloudFront distribution
  cost_filter {
    name = "Service"
    values = [
      "Amazon CloudFront"
    ]
  }

  cost_filter {
    name = "LinkedAccount"
    values = [
      data.aws_caller_identity.current.account_id
    ]
  }

  # Create notifications for each threshold
  dynamic "notification" {
    for_each = var.budget_alert_thresholds
    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = notification.value
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_sns_topic_arns = [var.sns_topic_arn]
    }
  }
}

# Additional budget for S3 costs (data transfer, requests)
resource "aws_budgets_budget" "s3" {
  name         = "${var.name}-s3-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_amount * 0.1) # 10% of CloudFront budget
  limit_unit   = "USD"
  time_unit    = var.budget_time_unit

  cost_filter {
    name = "Service"
    values = [
      "Amazon Simple Storage Service"
    ]
  }

  cost_filter {
    name = "LinkedAccount"
    values = [
      data.aws_caller_identity.current.account_id
    ]
  }

  # Notifications at higher thresholds since S3 costs should be minimal
  dynamic "notification" {
    for_each = [80, 100, 150]
    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = notification.value
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_sns_topic_arns = [var.sns_topic_arn]
    }
  }
}

# CloudWatch Alarm for sudden traffic spikes based on CloudFront requests
resource "aws_cloudwatch_metric_alarm" "traffic_spike" {
  alarm_name          = "${var.name}-cloudfront-traffic-spike"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Requests"
  namespace           = "AWS/CloudFront"
  period              = 3600 # 1 hour
  statistic           = "Sum"
  threshold           = 1000000 # 1 million requests per hour
  alarm_description   = "Alert on unusual traffic spikes to prevent unexpected costs"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = merge(var.tags, {
    Name = "${var.name}-traffic-spike-alarm"
  })
}

# CloudWatch Alarm for data transfer spikes
resource "aws_cloudwatch_metric_alarm" "bandwidth_spike" {
  alarm_name          = "${var.name}-cloudfront-bandwidth-spike"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesDownloaded"
  namespace           = "AWS/CloudFront"
  period              = 3600 # 1 hour
  statistic           = "Sum"
  threshold           = 107374182400 # 100 GB per hour
  alarm_description   = "Alert on unusual bandwidth usage to prevent unexpected costs"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = merge(var.tags, {
    Name = "${var.name}-bandwidth-spike-alarm"
  })
}

# Cost Anomaly Detector for unusual spending patterns
resource "aws_ce_anomaly_monitor" "cloudfront" {
  name              = "${var.name}-cloudfront-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "cloudfront" {
  name      = "${var.name}-cloudfront-anomaly-subscription"
  frequency = "IMMEDIATE"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.cloudfront.arn
  ]

  subscriber {
    type    = "SNS"
    address = var.sns_topic_arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.anomaly_threshold)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}
