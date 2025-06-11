# CloudWatch Alarms for ASG monitoring

# High CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "asg-${var.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_description   = "This metric monitors ASG CPU utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

# Low CPU utilization alarm (for scale down)
resource "aws_cloudwatch_metric_alarm" "asg_cpu_low" {
  alarm_name          = "asg-${var.name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  alarm_description   = "This metric monitors ASG CPU for potential scale down"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

# Unhealthy instances alarm
resource "aws_cloudwatch_metric_alarm" "asg_unhealthy_instances" {
  alarm_name          = "asg-${var.name}-unhealthy-instances"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert when ASG has unhealthy instances"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

# Group in-service instances alarm
resource "aws_cloudwatch_metric_alarm" "asg_group_in_service_instances" {
  alarm_name          = "asg-${var.name}-insufficient-instances"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Average"
  threshold           = var.count_min
  alarm_description   = "Alert when ASG has fewer instances than minimum"
  treat_missing_data  = "breaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

# Memory utilization alarm (requires CloudWatch agent)
resource "aws_cloudwatch_metric_alarm" "asg_memory_high" {
  alarm_name          = "asg-${var.name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_high_threshold
  alarm_description   = "This metric monitors ASG memory utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
