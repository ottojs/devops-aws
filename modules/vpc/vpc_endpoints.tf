
# Documentation
# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "gateways" {
  for_each          = toset(var.vpc_endpoints == true ? ["s3", "dynamodb"] : [])
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_default_route_table.private.id, aws_route_table.public.id]
  tags = merge(var.tags, {
    Name = "vpc-endpoint-${each.value}"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "interfaces" {
  for_each            = toset(var.vpc_endpoints == true ? ["kms", "logs", "secretsmanager", "ssm", "ec2messages", "ec2", "ssmmessages"] : [])
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpce[0].id,
  ]
  tags = merge(var.tags, {
    Name = "vpc-endpoint-${each.value}"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "vpce" {
  count       = var.vpc_endpoints ? 1 : 0
  name        = "vpc-endpoints"
  description = "VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "vpc-endpoints"
  })

  # HTTP from Anywhere
  # Use only for redirecting HTTPS (443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "ALLOW - HTTPS VPC"
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
