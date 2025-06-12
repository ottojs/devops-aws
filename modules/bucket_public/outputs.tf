
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
  value       = aws_cloudwatch_metric_alarm.cloudfront_4xx_error_rate.alarm_name
  description = "Name of the CloudWatch alarm for 4xx errors"
}

output "cloudwatch_alarm_5xx_name" {
  value       = aws_cloudwatch_metric_alarm.cloudfront_5xx_error_rate.alarm_name
  description = "Name of the CloudWatch alarm for 5xx errors"
}

output "budget_name" {
  value       = aws_budgets_budget.cloudfront.name
  description = "Name of the AWS Budget for cost monitoring"
}

output "anomaly_monitor_arn" {
  value       = aws_ce_anomaly_monitor.cloudfront.arn
  description = "ARN of the Cost Anomaly Monitor"
}

output "traffic_spike_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.traffic_spike.alarm_name
  description = "Name of the CloudWatch alarm for traffic spikes"
}

output "bandwidth_spike_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.bandwidth_spike.alarm_name
  description = "Name of the CloudWatch alarm for bandwidth spikes"
}
