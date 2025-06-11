
output "bucket" {
  value = aws_s3_bucket.main
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.main
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}

output "custom_domain_url" {
  value       = "https://${local.fqdn}"
  description = "Full URL of the custom domain if configured"
}

output "website_url" {
  # "https://${aws_cloudfront_distribution.main.domain_name}"
  value       = "https://${local.fqdn}"
  description = "Primary URL to access the website (custom domain or CloudFront domain)"
}

output "cloudwatch_alarm_4xx_name" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cloudfront_4xx_error_rate[0].alarm_name : null
  description = "Name of the CloudWatch alarm for 4xx errors"
}

output "cloudwatch_alarm_5xx_name" {
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cloudfront_5xx_error_rate[0].alarm_name : null
  description = "Name of the CloudWatch alarm for 5xx errors"
}

output "budget_name" {
  value       = var.enable_budget_alerts ? aws_budgets_budget.cloudfront[0].name : null
  description = "Name of the AWS Budget for cost monitoring"
}

output "anomaly_monitor_arn" {
  value       = var.enable_anomaly_detection ? aws_ce_anomaly_monitor.cloudfront[0].arn : null
  description = "ARN of the Cost Anomaly Monitor"
}

output "traffic_spike_alarm_name" {
  value       = var.enable_budget_alerts ? aws_cloudwatch_metric_alarm.traffic_spike[0].alarm_name : null
  description = "Name of the CloudWatch alarm for traffic spikes"
}

output "bandwidth_spike_alarm_name" {
  value       = var.enable_budget_alerts ? aws_cloudwatch_metric_alarm.bandwidth_spike[0].alarm_name : null
  description = "Name of the CloudWatch alarm for bandwidth spikes"
}
