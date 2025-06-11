output "topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.main.arn
}

output "topic_name" {
  description = "SNS topic Name"
  value       = aws_sns_topic.main.name
}

output "topic_id" {
  description = "SNS topic ID"
  value       = aws_sns_topic.main.id
}

output "subscription_arn" {
  description = "Subscription ARN (if created)"
  value       = try(aws_sns_topic_subscription.main.arn, null)
}
