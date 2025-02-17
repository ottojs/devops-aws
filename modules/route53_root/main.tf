
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "root_public" {
  name    = "${var.root_domain}."
  comment = "IaC"
  tags = merge(var.tags, {
    Public = "true"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "root_private" {
  name    = "${var.root_domain}."
  comment = "IaC"
  vpc {
    vpc_id = var.vpc.id
  }
  tags = merge(var.tags, {
    Public = "false"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "root_public_caa" {
  zone_id = aws_route53_zone.root_public.zone_id
  name    = "${var.root_domain}."
  type    = "CAA"
  ttl     = 3600
  records = [
    "0 issue \"amazon.com\"",
    "0 issue \"letsencrypt.org\""
  ]
}
