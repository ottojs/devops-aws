
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "default" {
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
  parameter_group_name                = "tf-rds-postgresql-17"
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
  storage_type            = "gp3"
  vpc_security_group_ids  = [aws_security_group.postgresql.id]
  backup_retention_period = var.backup_days
  backup_window           = "05:00-07:00" # UTC/GMT

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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_db_parameter_group" "postgresql17" {
  name   = "tf-rds-postgresql-17"
  family = "postgres17"

  parameter {
    name         = "authentication_timeout"
    value        = "10"
    apply_method = "immediate"
  }

  tags = merge(var.tags, {
    Name = "tf-rds-postgresql-17"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "main" {
  name       = "tf-db-postgresql-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "tf-db-postgresql-subnets"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "postgresql" {
  name        = "secgrp-rds-postgresql"
  description = "PostgreSQL Security Group"
  vpc_id      = var.vpc.id

  tags = merge(var.tags, {
    Name = "secgrp-rds-postgresql"
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
