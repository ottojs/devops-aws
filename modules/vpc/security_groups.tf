
# WARNING: DO NOT USE
# aws_vpc_security_group_ingress_rule
# aws_vpc_security_group_egress_rule

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  # Intentionally Nothing Allowed
  # Create another security group for your needs
  tags = {
    Name = "default-DONOTUSE"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "main" {
  name        = "secgrp-main"
  description = "Main"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "secgrp-main"
    APP  = var.tag_app
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
    description = "ALLOW - SSH from Remote"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
    description = "ALLOW - SSH from VPC"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - ICMP PING ECHO"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - All Outbound"
  }
}
