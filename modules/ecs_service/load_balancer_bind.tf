
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "default" {
  listener_arn = var.lb_listener.arn
  priority     = 1
  condition {
    host_header {
      values = ["${var.name}.${var.root_domain}"]
    }
  }
  action {
    type = "forward"
    # Simplified Version
    # target_group_arn = aws_lb_target_group.main.arn
    #
    # TODO: Multiple Blue/Green
    forward {
      target_group {
        arn    = aws_lb_target_group.main.arn
        weight = 80
      }
      # target_group {
      #   arn    = aws_lb_target_group.green.arn
      #   weight = 20
      # }
    }
  }
  tags = {
    Name = var.name
    App  = var.tag_app
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "main" {
  #name                         = "tg-${var.name}"
  name_prefix                   = var.name
  port                          = 8080
  protocol                      = "HTTP"
  vpc_id                        = var.vpc.id
  target_type                   = "ip"
  deregistration_delay          = 300
  load_balancing_algorithm_type = "round_robin"
  #preserve_client_ip = true
  protocol_version = "HTTP1"
  slow_start       = 0
  ip_address_type  = "ipv4"

  # WARNING: Try to not enable this, only use it as a last resort
  stickiness {
    type    = "app_cookie" # lb_cookie, app_cookie... others when not ALB
    enabled = false
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "10"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    App = var.tag_app
  }
}
