
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "default" {
  count        = var.mode == "server" && var.skeleton == false ? 1 : 0
  listener_arn = data.aws_lb_listener.https[0].arn
  priority     = var.priority
  condition {
    host_header {
      values = concat(["${var.name}.${var.root_domain}"], var.additional_hosts)
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
        arn    = aws_lb_target_group.main[0].arn
        weight = 80
      }
      # target_group {
      #   arn    = aws_lb_target_group.green.arn
      #   weight = 20
      # }
    }
  }
  tags = merge(var.tags, {
    Name = var.name
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "main" {
  count = var.mode == "server" ? 1 : 0
  name  = "tg-${var.name}"
  #name_prefix                   = var.name
  port                          = 8080
  protocol                      = "HTTP"
  vpc_id                        = var.vpc.id
  target_type                   = "ip"
  deregistration_delay          = 30
  load_balancing_algorithm_type = "round_robin"
  #preserve_client_ip = true
  protocol_version = "HTTP1"
  slow_start       = 0
  ip_address_type  = "ipv4" # "dualstack"

  # WARNING: Try to not enable this, only use it as a last resort
  stickiness {
    type    = "app_cookie" # lb_cookie, app_cookie... others when not ALB
    enabled = false
  }

  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "5"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = var.tags
}
