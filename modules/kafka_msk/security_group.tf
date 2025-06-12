
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "msk_sg" {
  name        = "msk-${var.name}"
  description = "MSK ${var.name}"
  vpc_id      = var.vpc.id

  # TLS port (SSL)
  dynamic "ingress" {
    for_each = var.allowed_security_groups
    content {
      description     = "TLS from ${ingress.value.name}"
      from_port       = 9094
      to_port         = 9094
      protocol        = "tcp"
      security_groups = [ingress.value.id]
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "TLS from allowed CIDRs"
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # SASL/SCRAM port (only if SASL users are configured)
  dynamic "ingress" {
    for_each = length(var.sasl_scram_users) > 0 ? var.allowed_security_groups : []
    content {
      description     = "SASL/SCRAM from ${ingress.value.name}"
      from_port       = 9096
      to_port         = 9096
      protocol        = "tcp"
      security_groups = [ingress.value.id]
    }
  }

  dynamic "ingress" {
    for_each = length(var.sasl_scram_users) > 0 && length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "SASL/SCRAM from allowed CIDRs"
      from_port   = 9096
      to_port     = 9096
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # IAM authentication port
  dynamic "ingress" {
    for_each = var.allowed_security_groups # IAM auth always enabled
    content {
      description     = "IAM auth from ${ingress.value.name}"
      from_port       = 9098
      to_port         = 9098
      protocol        = "tcp"
      security_groups = [ingress.value.id]
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "IAM auth from allowed CIDRs"
      from_port   = 9098
      to_port     = 9098
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Egress for HTTPS (AWS API calls)
  egress {
    description = "HTTPS to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress for internal Kafka communication (self)
  egress {
    description = "Internal Kafka communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  tags = merge(var.tags, {
    Name = "msk-${var.name}"
  })
}
