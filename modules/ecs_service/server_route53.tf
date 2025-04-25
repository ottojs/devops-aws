
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root" {
  count        = var.mode == "server" ? 1 : 0
  name         = "${var.root_domain}."
  private_zone = !var.public
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main" {
  count   = var.mode == "server" && var.skeleton == false ? 1 : 0
  zone_id = data.aws_route53_zone.root[0].zone_id
  name    = "${var.name}.${var.root_domain}"
  type    = "A"
  # Alias
  alias {
    name                   = data.aws_lb.main[0].dns_name
    zone_id                = data.aws_lb.main[0].zone_id
    evaluate_target_health = true
  }
  # Static
  # records = [data.aws_lb.main[0].dns_name]
  # ttl     = 60
}
