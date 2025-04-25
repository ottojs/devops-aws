
output "endpoint" {
  value = trimsuffix(aws_db_instance.main.endpoint, ":3306")
}

output "db_name" {
  value = var.db_name
}
