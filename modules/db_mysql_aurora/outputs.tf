
output "cluster_id" {
  description = "Aurora MySQL cluster identifier"
  value       = aws_rds_cluster.aurora_mysql.id
}

output "cluster_arn" {
  description = "Aurora MySQL cluster ARN"
  value       = aws_rds_cluster.aurora_mysql.arn
}

output "cluster_endpoint" {
  description = "Aurora MySQL cluster endpoint (writer)"
  value       = aws_rds_cluster.aurora_mysql.endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora MySQL cluster reader endpoint (same as writer for single instance)"
  value       = aws_rds_cluster.aurora_mysql.reader_endpoint
}

output "cluster_port" {
  description = "Aurora MySQL cluster port"
  value       = aws_rds_cluster.aurora_mysql.port
}
