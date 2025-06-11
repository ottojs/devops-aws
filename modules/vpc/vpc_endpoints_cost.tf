
# Documentation for SSM VPC Endpoints
# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html

# These are about $8/mo/endpoint/az (e.g., $8/mo * 10 Services * 3 AZs = ~$240/mo)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "interfaces" {
  for_each            = toset(var.dev_mode ? [] : var.vpc_endpoints_interface)
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpce[0].id,
  ]
  tags = merge(var.tags, {
    Name = "vpce-${each.value}"
  })
}

# Security Groups only apply to Interface VPC Endpoints
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "vpce" {
  count       = var.dev_mode ? 0 : 1
  name        = "vpc-endpoints"
  description = "VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "vpc-endpoints"
  })

  # HTTPS from VPC
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
