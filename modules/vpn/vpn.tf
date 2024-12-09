
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
resource "aws_acm_certificate" "vpn" {
  private_key      = file(var.file_key)
  certificate_body = file(var.file_crt)
  # certificate_chain = ... optional, not used in our self-signed example
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "vpn" {
  name         = "vpn/cvpn-${var.name}"
  kms_key_id   = var.kms_key.arn
  skip_destroy = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream
resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "cvpn-${var.name}-${var.vpc.id}"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint
resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "cvpn-${var.name}"
  server_certificate_arn = aws_acm_certificate.vpn.arn
  client_cidr_block      = var.cidr
  security_group_ids     = [aws_security_group.entry.id]
  self_service_portal    = "disabled"
  split_tunnel           = true
  session_timeout_hours  = 8
  vpc_id                 = var.vpc.id
  transport_protocol     = "udp"
  vpn_port               = 443
  dns_servers            = ["1.0.0.1", "1.1.1.1"] # Cloudflare, use 8.8.8.8 for Google

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }
  tags = {
    Name = "cvpn-${var.name}"
    App  = var.tag_app
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule
resource "aws_ec2_client_vpn_authorization_rule" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = var.vpc.cidr_block
  authorize_all_groups   = true
  description            = "Allow Access to All VPC"
  timeouts {
    create = "30m"
    delete = "15m"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association
resource "aws_ec2_client_vpn_network_association" "vpn" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = var.subnet.id
  timeouts {
    create = "30m"
    delete = "15m"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "entry" {
  name        = "secgrp-cvpn-${var.name}-entry"
  description = "VPN Entry"
  vpc_id      = var.vpc.id

  tags = {
    Name = "secgrp-cvpn-${var.name}-entry"
    APP  = var.tag_app
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = var.allowed_cidrs
    description = "ALLOW - HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - All Outbound"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "machine" {
  name        = "secgrp-cvpn-${var.name}-machine"
  description = "VPN Machine"
  vpc_id      = var.vpc.id

  tags = {
    Name = "secgrp-cvpn-${var.name}-machine"
    APP  = var.tag_app
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet.cidr_block]
    description = "ALLOW - SSH"
  }
}
