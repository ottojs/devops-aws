
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root_private" {
  count        = var.mode == "server" ? 1 : 0
  name         = "${var.root_domain}."
  private_zone = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root_public" {
  count        = var.mode == "server" && var.public == true ? 1 : 0
  name         = "${var.root_domain}."
  private_zone = false
}

# There will always be a private record for internal systems to resolve (bastion)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "main" {
  count   = var.mode == "server" && var.skeleton == false ? 1 : 0
  zone_id = data.aws_route53_zone.root_private[0].zone_id
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "public" {
  count   = var.mode == "server" && var.skeleton == false && var.public == true ? 1 : 0
  zone_id = data.aws_route53_zone.root_public[0].zone_id
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
