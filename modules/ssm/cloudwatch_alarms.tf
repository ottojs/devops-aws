
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter
resource "aws_cloudwatch_log_metric_filter" "ssm_failed_connections" {
  name           = "ssm-failed-connections"
  log_group_name = aws_cloudwatch_log_group.ssm_sessions.name
  pattern        = "[time, request_id, event_type=SessionManagerPlugin*, event_name=ConnectToSession*, status=Failed*]"

  metric_transformation {
    name      = "SSMFailedConnections"
    namespace = "SSM/Sessions"
    value     = "1"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "ssm_failed_connections" {
  alarm_name          = "ssm-failed-connection-attempts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SSMFailedConnections"
  namespace           = "SSM/Sessions"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Triggers when more than 5 SSM connection attempts fail within 10 minutes"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

#####
#####

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter
resource "aws_cloudwatch_log_metric_filter" "ssm_unusual_session_duration" {
  name           = "ssm-unusual-session-duration"
  log_group_name = aws_cloudwatch_log_group.ssm_sessions.name
  pattern        = "[time, request_id, event_type=SessionManagerPlugin*, event_name=TerminateSession*, status=Success*, duration>7200000]"

  metric_transformation {
    name      = "SSMUnusualSessionDuration"
    namespace = "SSM/Sessions"
    value     = "1"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "ssm_unusual_session_duration" {
  alarm_name          = "ssm-unusual-session-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SSMUnusualSessionDuration"
  namespace           = "SSM/Sessions"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Triggers when SSM session duration exceeds 2 hours" # 7200000
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

#####
#####

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter
resource "aws_cloudwatch_log_metric_filter" "ssm_root_user_sessions" {
  name           = "ssm-root-user-sessions"
  log_group_name = aws_cloudwatch_log_group.ssm_sessions.name
  pattern        = "[time, request_id, event_type=SessionManagerPlugin*, event_name=StartSession*, status=Success*, target_user=root*]"

  metric_transformation {
    name      = "SSMRootUserSessions"
    namespace = "SSM/Sessions"
    value     = "1"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "ssm_root_user_sessions" {
  alarm_name          = "ssm-root-user-sessions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SSMRootUserSessions"
  namespace           = "SSM/Sessions"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Triggers when root user SSM sessions are initiated"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}
