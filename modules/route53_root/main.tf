
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

############################
### Wildcard Certificate ###
############################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.root_domain}"
  validation_method = "DNS"
  tags              = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "root_public_acm" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = aws_route53_zone.root_public.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

#############
### DMARC ###
#############

# Tool: https://easydmarc.com/tools/dmarc-record-generator
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "root_public_dmarc" {
  zone_id = aws_route53_zone.root_public.zone_id
  name    = "_dmarc.${var.root_domain}."
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1; p=reject;"]
}
