
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl
resource "aws_default_network_acl" "main" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
  subnet_ids = sort(
    concat(
      values(aws_subnet.public)[*].id,
      values(aws_subnet.private)[*].id
    )
  )
  tags = {
    Name = "nacl-${aws_vpc.main.id}-default"
  }
  # We use the resources below
  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# HTTP from Anywhere
# Use only for redirecting HTTPS (443)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_tcp_80" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 10
  egress         = false
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# HTTPS from Anywhere
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_tcp_443" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 20
  egress         = false
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# VPN Connections from Anywhere
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_udp_443" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 30
  egress         = false
  rule_action    = "allow"
  protocol       = "udp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# SSH (Linux) from VPC CIDR
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_tcp_22" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 40
  egress         = false
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 22
  to_port        = 22
}

# Remote Desktop (Windows) from VPC CIDR
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_tcp_3389" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 50
  egress         = false
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 3389
  to_port        = 3389
}

# Return-Traffic TCP
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_tcp_return" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 60
  egress         = false
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 4096
  to_port        = 65535
}

# Return-Traffic UDP
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_udp_return" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 70
  egress         = false
  rule_action    = "allow"
  protocol       = "udp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 4096
  to_port        = 65535
}

# Allow All Outbound IPv4
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "default_outbound" {
  network_acl_id = aws_default_network_acl.main.id
  rule_number    = 10
  egress         = true
  rule_action    = "allow"
  protocol       = -1
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
