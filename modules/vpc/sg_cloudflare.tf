
# https://www.cloudflare.com/ips/
locals {
  cf_ipv4 = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
  ]
  cf_ipv6 = [
    "2400:cb00::/32",
    "2606:4700::/32",
    "2803:f800::/32",
    "2405:b500::/32",
    "2405:8100::/32",
    "2a06:98c0::/29",
    "2c0f:f248::/32",
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "cloudflare" {
  name        = "cloudflare"
  description = "Cloudflare"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "cloudflare"
  })

  # HTTP from Cloudflare
  # Use only for redirecting HTTPS (443)
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = local.cf_ipv4
    ipv6_cidr_blocks = local.cf_ipv6
    description      = "ALLOW - HTTP Cloudflare"
  }

  # HTTPS from Cloudflare
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = local.cf_ipv4
    ipv6_cidr_blocks = local.cf_ipv6
    description      = "ALLOW - HTTPS Cloudflare"
  }

}
