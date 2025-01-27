
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = !var.public
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${var.name}.${var.root_domain}"
  type    = "A"
  # Alias
  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = true
  }
  # Static
  # records = [var.load_balancer.dns_name]
  # ttl     = 60
}
