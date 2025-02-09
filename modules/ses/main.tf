
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_configuration_set
resource "aws_ses_configuration_set" "config_set" {
  name                       = "config-set"
  reputation_metrics_enabled = true
  sending_enabled            = true

  delivery_options {
    tls_policy = "Require"
  }

  tracking_options {
    # Can also be a subdomain
    custom_redirect_domain = var.root_domain
  }
}

#####
#####

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity
resource "aws_ses_domain_identity" "verify" {
  domain = var.root_domain
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "verify" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "_amazonses.${var.root_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.verify.verification_token]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity_verification
resource "aws_ses_domain_identity_verification" "verify" {
  domain     = var.root_domain
  depends_on = [aws_route53_record.verify, aws_route53_record.dkim]
}

#####
#####

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.verify.domain
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${aws_ses_domain_dkim.main.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600" # 10 minutes
  records = ["${aws_ses_domain_dkim.main.dkim_tokens[count.index]}.dkim.amazonses.com"]
}
