
# WARNING: This is for testing purposes only
# This will switch to ValKey v8.x very soon (an open-source Redis fork)
# More info: https://valkey.io/blog/valkey-8-ga/
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster
resource "aws_elasticache_cluster" "valkey" {
  cluster_id                 = var.name
  engine                     = "redis" # valkey
  node_type                  = var.machine_type
  num_cache_nodes            = 1
  parameter_group_name       = "default.redis7" # default.valkey8, default.valkey8.cluster.on
  engine_version             = var.engine_version
  port                       = 6379
  az_mode                    = "single-az"
  subnet_group_name          = aws_elasticache_subnet_group.valkey.name
  auto_minor_version_upgrade = false
  apply_immediately          = true
  maintenance_window         = "sun:05:00-sun:09:00" # UTC/GMT
  network_type               = "ipv4"
  snapshot_retention_limit   = 10
  snapshot_window            = "00:00-04:00"
  final_snapshot_identifier  = "final-snapshot-${var.name}"
  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user
resource "aws_elasticache_user" "valkey" {
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
resource "aws_elasticache_subnet_group" "valkey" {
  name        = "tf-db-valkey-subnets"
  description = "tf-db-valkey-subnets"
  subnet_ids  = local.subnet_ids
  tags = merge(var.tags, {
    Name = "tf-db-valkey-subnets"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "valkey" {
  name        = "secgrp-db-valkey"
  description = "Database ValKey"
  vpc_id      = var.vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - ValKey Inbound VPC"
  }

  #   egress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = ["0.0.0.0/0"]
  #     description = "ALLOW - All Outbound"
  #   }

  tags = merge(var.tags, {
    Name = "secgrp-db-valkey"
  })
}
