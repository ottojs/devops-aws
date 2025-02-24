
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group
resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id       = var.name
  description                = "Valkey"
  apply_immediately          = true # TODO: Review
  at_rest_encryption_enabled = true
  auth_token                 = var.password
  auth_token_update_strategy = "ROTATE"
  auto_minor_version_upgrade = false # TODO: Review
  automatic_failover_enabled = true
  cluster_mode               = "enabled"
  data_tiering_enabled       = false
  engine                     = "valkey"
  engine_version             = var.engine_version
  final_snapshot_identifier  = "final-snapshot-${var.name}"
  ip_discovery               = "ipv4"
  kms_key_id                 = var.kms_key.arn
  maintenance_window         = "sun:05:00-sun:09:00" # after snapshot
  multi_az_enabled           = true
  network_type               = "ipv4"
  node_type                  = var.machine_type
  notification_topic_arn     = data.aws_sns_topic.devops.arn
  num_cache_clusters         = 2
  # num_node_groups - conflicts with num_cache_clusters
  parameter_group_name = "default.valkey8.cluster.on" # "default.valkey8"
  port                 = "6379"
  # preferred_cache_cluster_azs
  # replicas_per_node_group - requires num_node_groups
  security_group_ids = [aws_security_group.valkey.id]
  # security_group_names
  # snapshot_arns
  # snapshot_name (used for restore)
  snapshot_retention_limit   = 10
  snapshot_window            = "00:00-04:00" # before maintenance
  subnet_group_name          = aws_elasticache_subnet_group.valkey.name
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"
  # user_group_ids

  # TODO
  # log_delivery_configuration {
  #   destination = "/aws/elasticache/${var.name}/slow-log"
  #   destination_type = "cloudwatch-logs"
  #   log_format = "json"
  #   log_type = "slow-log"
  # }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user
# resource "aws_elasticache_user" "valkey" {
#   user_id       = "app"
#   user_name     = "app"
#   access_string = "on ~* +@all"
#   engine        = "REDIS"

#   # Passwords length must be between 16-128 characters
#   authentication_mode {
#     type      = "password"
#     passwords = var.passwords
#   }
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group
resource "aws_elasticache_subnet_group" "valkey" {
  name        = "db-vk-${var.name}"
  description = "db-vk-${var.name}"
  subnet_ids  = var.subnet_ids
  tags = merge(var.tags, {
    Name = "db-${var.name}"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "valkey" {
  name        = "db-vk-${var.name}"
  description = "Database Valkey ${var.name}"
  vpc_id      = var.vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - Valkey Inbound VPC"
  }

  tags = merge(var.tags, {
    Name = "db-vk-${var.name}"
  })
}
