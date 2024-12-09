
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate
data "aws_acm_certificate" "main" {
  domain   = "*.${var.root_domain}"
  statuses = ["ISSUED"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.subnet_ids

  drop_invalid_header_fields = true
  ip_address_type            = "ipv4"
  idle_timeout               = 60
  enable_xff_client_port     = false
  enable_http2               = true
  xff_header_processing_mode = "append"

  # needs KMS AWS-managed
  # delivery.logs.amazonaws.com on KMS Policy
  # access_logs {
  #   bucket  = var.log_bucket_id
  #   prefix  = "loadbalancers-access/main-alb"
  #   enabled = true
  # }

  # connection_logs {
  #   bucket  = var.log_bucket_id
  #   prefix  = "loadbalancers-connection/main-alb"
  #   enabled = true
  # }

  tags = {
    APP = var.tag_app
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
    APP  = var.tag_app
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
