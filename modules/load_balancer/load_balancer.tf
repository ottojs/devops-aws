
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate
data "aws_acm_certificate" "main" {
  domain   = "*.${var.root_domain}"
  statuses = ["ISSUED"]
}

# Load Balancer Logs
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
#
# Oddly, customer-managed KMS keys are not supported per
# https://repost.aws/questions/QU2SV2jkZRSkuhNL-EGUgyTA/storing-application-load-balancer-access-logs-in-a-kms-encrypted-s3-bucket

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.subnet_ids

  client_keep_alive                           = 3600 # default
  desync_mitigation_mode                      = "strictest"
  dns_record_client_routing_policy            = "any_availability_zone" # default
  drop_invalid_header_fields                  = true
  enable_deletion_protection                  = false # default
  enable_http2                                = true  # default
  enable_tls_version_and_cipher_suite_headers = false # default
  enable_xff_client_port                      = false # default
  enable_waf_fail_open                        = false # default
  enable_zonal_shift                          = false # default
  idle_timeout                                = 60    # default
  internal                                    = false # TODO: variable
  ip_address_type                             = "ipv4"
  preserve_host_header                        = false    # default (this should be set by the LoadBalancer)
  xff_header_processing_mode                  = "append" # default

  # TODO
  # Default log prefix is /AWSLogs/{ACCOUNTID}
  # We'll use the default for now to see how integration with tools goes
  access_logs {
    bucket = var.log_bucket.id
    # prefix  = "devops/aws/load-balancer/${var.name}/access"
    enabled = true
  }
  connection_logs {
    bucket = var.log_bucket.id
    # prefix  = "devops/aws/load-balancer/${var.name}/connection"
    enabled = true
  }

  tags = {
    App = var.tag_app
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Offline"
      status_code  = "200"
    }
    # If you wanted a default service use:
    # type             = "forward"
    # target_group_arn = aws_lb_target_group.main.arn
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "alb" {
  name        = "secgrp-alb"
  description = "ALB"
  vpc_id      = var.vpc.id

  tags = {
    Name = "secgrp-alb"
    App  = var.tag_app
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - HTTP Inbound"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALLOW - HTTPS Inbound"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - All Outbound"
  }
}
