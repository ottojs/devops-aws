
# Security Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "aurora" {
  name        = "aurora-mysql-${var.name}"
  description = "Security group for Aurora MySQL ${var.name}"
  vpc_id      = var.vpc.id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "aurora-mysql-${var.name}"
  })
}

# Ingress rule - allow access from VPC CIDR
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "aurora_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.vpc.cidr_block]
  security_group_id = aws_security_group.aurora.id
  description       = "MySQL access from VPC"
}

# Egress rule for HTTPS
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "aurora_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aurora.id
  description       = "HTTPS for AWS API calls"
}
