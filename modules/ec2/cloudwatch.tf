
# Instance Recovery Alarm
resource "aws_cloudwatch_metric_alarm" "instance_recovery" {
  count               = var.dev_mode ? 0 : 1
  alarm_name          = "${local.name}-recovery"
  alarm_description   = "Trigger instance recovery when instance status check fails"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.region}:ec2:recover"]

  dimensions = {
    InstanceId = aws_instance.ec2.id
  }

  tags = merge(var.tags, {
    Name = "${local.name}-recovery-alarm"
  })
}
