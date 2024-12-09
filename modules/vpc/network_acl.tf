
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl
resource "aws_default_network_acl" "main" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
  tags = {
    Name = "nacl-${aws_vpc.main.id}-default"
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 10
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 20
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # For VPN
  ingress {
    protocol   = "udp"
    rule_no    = 30
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # For SSH in VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 40
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 22
    to_port    = 22
  }

  # For ELB/EC2/ECS in VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 50
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 8080
    to_port    = 8080
  }

  # For Return-Traffic
  ingress {
    protocol   = "tcp"
    rule_no    = 60
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 4096
    to_port    = 65535
  }

  egress {
    protocol   = -1
    rule_no    = 10
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = -1
    rule_no         = 20
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  # TODO: Refine
  lifecycle {
    ignore_changes = [subnet_ids]
  }
}
