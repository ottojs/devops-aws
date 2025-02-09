
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "main" {
  name        = "secgrp-ecs-${var.name}"
  description = "ECS Task: ${var.name}"
  vpc_id      = var.vpc.id

  tags = merge(var.tags, {
    Name = "secgrp-ecs-${var.name}"
  })

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # TODO: Refine
    # This is required for Secrets Manager
    cidr_blocks = ["0.0.0.0/0"] #[var.vpc.cidr_block]
    description = "ALLOW - All Outbound"
  }
}
