# CloudWatch Alarms for CloudFront Distribution
# Monitor 4xx and 5xx error rates

# 4xx Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "cloudfront_4xx_error_rate" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-cloudfront-4xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = var.alarm_4xx_threshold
  alarm_description   = "This metric monitors CloudFront 4xx error rate"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "(m1/m2)*100"
    label       = "4xx Error Rate"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "4xxErrorRate"
      namespace   = "AWS/CloudFront"
      period      = var.alarm_period
      stat        = "Sum"
      dimensions = {
        DistributionId = aws_cloudfront_distribution.main.id
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Requests"
      namespace   = "AWS/CloudFront"
      period      = var.alarm_period
      stat        = "Sum"
      dimensions = {
        DistributionId = aws_cloudfront_distribution.main.id
      }
    }
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []
  ok_actions    = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(var.tags, {
    Name = "${var.name}-cloudfront-4xx-alarm"
  })
}

# 5xx Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_error_rate" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-cloudfront-5xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = var.alarm_5xx_threshold
  alarm_description   = "This metric monitors CloudFront 5xx error rate"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "(m1/m2)*100"
    label       = "5xx Error Rate"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "5xxErrorRate"
      namespace   = "AWS/CloudFront"
      period      = var.alarm_period
      stat        = "Sum"
      dimensions = {
        DistributionId = aws_cloudfront_distribution.main.id
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Requests"
      namespace   = "AWS/CloudFront"
      period      = var.alarm_period
      stat        = "Sum"
      dimensions = {
        DistributionId = aws_cloudfront_distribution.main.id
      }
    }
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []
  ok_actions    = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(var.tags, {
    Name = "${var.name}-cloudfront-5xx-alarm"
  })
}

# High 4xx Error Count Alarm (absolute count, not percentage)
resource "aws_cloudwatch_metric_alarm" "cloudfront_4xx_count" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-cloudfront-4xx-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 100
  alarm_description   = "This metric monitors high volume of 4xx errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(var.tags, {
    Name = "${var.name}-cloudfront-4xx-count-alarm"
  })
}

# Origin Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "cloudfront_origin_error_rate" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-cloudfront-origin-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = 5
  alarm_description   = "This metric monitors CloudFront origin error rate"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "(m1/m2)*100"
    label       = "Origin Error Rate"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "OriginLatency"
      namespace   = "AWS/CloudFront"
      period      = var.alarm_period
      stat        = "SampleCount"
      dimensions = {
        DistributionId = aws_cloudfront_distribution.main.id
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Requests"
      namespace   = "AWS/CloudFront"
      period      = var.alarm_period
      stat        = "Sum"
      dimensions = {
        DistributionId = aws_cloudfront_distribution.main.id
      }
    }
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(var.tags, {
    Name = "${var.name}-cloudfront-origin-error-alarm"
  })
}