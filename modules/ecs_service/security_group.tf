
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "main" {
  name        = "secgrp-ecs-${var.name}"
  description = "ECS Task: ${var.name}"
  vpc_id      = var.vpc.id

  tags = {
    Name = "secgrp-ecs-${var.name}"
    App  = var.tag_app
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - HTTP ALT Inbound VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc.cidr_block]
    description = "ALLOW - All Outbound"
  }
}
