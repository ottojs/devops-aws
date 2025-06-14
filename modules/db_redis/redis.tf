
# WARNING: This is for testing purposes only
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id                 = var.name
  engine                     = "redis"
  node_type                  = var.machine_type
  num_cache_nodes            = 1
  parameter_group_name       = "default.redis7"
  engine_version             = var.engine_version
  port                       = 6379
  az_mode                    = "single-az"
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  auto_minor_version_upgrade = false
  apply_immediately          = true
  maintenance_window         = var.maintenance_window
  network_type               = "ipv4"
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  final_snapshot_identifier  = "redis-${var.name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user
resource "aws_elasticache_user" "redis" {
  user_id       = "app"
  user_name     = "app"
  access_string = "on ~* +@all"
  engine        = "REDIS"

  # Passwords length must be between 16-128 characters
  authentication_mode {
    type      = "password"
    passwords = var.passwords
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group
resource "aws_elasticache_subnet_group" "redis" {
  name        = "db-${var.name}"
  description = "db-${var.name}"
  subnet_ids  = local.subnet_ids
  tags = merge(var.tags, {
    Name = "db-${var.name}"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "redis" {
  name        = "db-rd-${var.name}"
  description = "Database Redis ${var.name}"
  vpc_id      = var.vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - Redis Inbound VPC"
  }

  #   egress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = ["0.0.0.0/0"]
  #     description = "ALLOW - All Outbound"
  #   }

  tags = merge(var.tags, {
    Name = "db-rd-${var.name}"
  })
}
