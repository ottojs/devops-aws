
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${var.name}.${var.root_domain}"
  type    = "CNAME"
  # Static
  records = [aws_opensearch_domain.main.endpoint]
  ttl     = 60

  # # Alias (doesn't work)
  # alias {
  #   name                   = var.name
  #   zone_id                = aws_opensearch_domain.main.endpoint
  #   evaluate_target_health = true
  # }
}
