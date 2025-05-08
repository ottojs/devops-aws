
output "endpoint" {
  value = aws_elasticache_replication_group.valkey.configuration_endpoint_address
}
