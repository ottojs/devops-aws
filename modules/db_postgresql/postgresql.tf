
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/instance/${var.name}/postgresql"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key.arn

  tags = merge(var.tags, {
    Name = "db-rds-${var.name}-postgresql-logs"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "main" {
  allocated_storage                   = 20
  max_allocated_storage               = var.storage_max
  identifier                          = var.name
  db_name                             = var.db_name
  engine                              = "postgres"
  engine_version                      = var.engine_version
  license_model                       = "postgresql-license"
  port                                = "5432"
  instance_class                      = var.machine_type
  username                            = var.admin_username
  manage_master_user_password         = true # conflicts with parameter: password
  parameter_group_name                = "rds-postgresql-17"
  apply_immediately                   = true
  allow_major_version_upgrade         = false
  auto_minor_version_upgrade          = false
  copy_tags_to_snapshot               = true
  iam_database_authentication_enabled = true
  multi_az                            = true
  network_type                        = "IPV4"
  storage_encrypted                   = true
  ca_cert_identifier                  = "rds-ca-rsa4096-g1"
  db_subnet_group_name                = aws_db_subnet_group.main.name
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = var.kms_key.arn

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#gp3-storage
  storage_type                    = "gp3"
  vpc_security_group_ids          = [aws_security_group.postgresql.id]
  backup_retention_period         = var.backup_days
  backup_window                   = "05:00-07:00" # UTC/GMT
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # TODO: Review
  engine_lifecycle_support  = "open-source-rds-extended-support-disabled"
  skip_final_snapshot       = true
  final_snapshot_identifier = "final-snapshot-postgresql-${var.name}"
  delete_automated_backups  = true
  deletion_protection       = false # TODO: Review

  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "db-rds-${var.name}.${var.root_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_db_instance.main.address]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_db_parameter_group" "postgresql17" {
  name   = "rds-postgresql-17"
  family = "postgres17"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "password_encryption"
    value        = "scram-sha-256"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_disconnections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_checkpoints"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "authentication_timeout"
    value        = "10"
    apply_method = "immediate"
  }

  tags = merge(var.tags, {
    Name = "rds-postgresql-17"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "main" {
  name       = "db-postgresql-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "db-postgresql-subnets"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "postgresql" {
  name        = "db-pg-${var.name}"
  description = "Database PostgreSQL ${var.name}"
  vpc_id      = var.vpc.id

  tags = merge(var.tags, {
    Name = "db-pg-${var.name}"
  })

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - PostgreSQL Inbound VPC"
  }

  #   egress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = ["0.0.0.0/0"]
  #     description = "ALLOW - All Outbound"
  #   }
}
