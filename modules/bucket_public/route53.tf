# Route53 Record for Custom Domain
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main" {
  count = var.create_route53_record ? 1 : 0

  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

# IPv6 Record
# CloudFront supports IPv6 independently of VPC configuration
# This improves global accessibility without affecting VPC IPv4 setup
resource "aws_route53_record" "ipv6" {
  count = var.create_route53_record ? 1 : 0

  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.fqdn
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
