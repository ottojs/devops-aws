
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
#
# Limited header modification
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/header-modification.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "main" {
  name                                        = var.name
  load_balancer_type                          = "application"
  internal                                    = !var.public
  security_groups                             = length(var.security_group_ids) != 0 ? var.security_group_ids : [aws_security_group.alb.id]
  subnets                                     = local.subnet_ids
  client_keep_alive                           = 3600 # default
  desync_mitigation_mode                      = "strictest"
  dns_record_client_routing_policy            = "any_availability_zone" # default
  drop_invalid_header_fields                  = true
  enable_deletion_protection                  = !var.dev_mode
  enable_http2                                = true  # default
  enable_tls_version_and_cipher_suite_headers = false # default
  enable_xff_client_port                      = false # default
  enable_waf_fail_open                        = false # default
  enable_zonal_shift                          = !var.dev_mode
  enable_cross_zone_load_balancing            = true # Better availability across AZs
  idle_timeout                                = var.idle_timeout
  ip_address_type                             = "ipv4"   # "dualstack"
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

  tags = merge(var.tags, {
    Public = var.public ? "true" : "false"
  })
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
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "503 - Service Offline"
      status_code  = "503"
    }
    # If you wanted a default service use:
    # type             = "forward"
    # target_group_arn = aws_lb_target_group.main.arn
  }

  # NOTE: ALB doesn't natively support adding custom response headers
  # Add headers in your application code

  tags = merge(var.tags, {
    Public = var.public ? "true" : "false"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "alb" {
  name        = var.name
  description = "ALB ${var.name}"
  vpc_id      = var.vpc.id

  tags = merge(var.tags, {
    Name   = var.name
    Public = var.public ? "true" : "false"
  })

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
