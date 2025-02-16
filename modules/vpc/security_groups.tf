
# WARNING: DO NOT USE
# aws_vpc_security_group_ingress_rule
# aws_vpc_security_group_egress_rule

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group
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

  tags = merge(var.tags, {
    Name = "secgrp-main"
  })

  # HTTP from Anywhere
  # Use only for redirecting HTTPS (443)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - HTTP"
  }

  # HTTPS from Anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - HTTPS"
  }

  # SSH (Linux) from VPC CIDR
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "ALLOW - SSH from VPC"
  }

  # Remote Desktop (Windows) from VPC CIDR
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "ALLOW - RDP from VPC"
  }

  # Ping from VPC CIDR
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "ALLOW - ICMP PING ECHO from VPC"
  }

  # All Outbound IPv4 Allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - All Outbound"
  }

}
