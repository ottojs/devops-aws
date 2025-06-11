
output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for the cluster"
  value       = local.main_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the cluster"
  value       = aws_cloudwatch_log_group.main.arn
}
