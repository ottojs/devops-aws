
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "main" {
  name        = "ecs-${var.name}"
  description = "ECS Task: ${var.name}"
  vpc_id      = var.vpc.id

  # Only if mode is server
  dynamic "ingress" {
    for_each = var.mode == "server" ? [1] : []
    content {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [var.vpc.cidr_block]
      description = "ALLOW - HTTP ALT Inbound VPC"
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # TODO: Refine
    # This is required for Secrets Manager
    cidr_blocks = ["0.0.0.0/0"] #[var.vpc.cidr_block]
    description = "ALLOW - All Outbound"
  }

  tags = merge(var.tags, {
    Name = "ecs-${var.name}"
  })
}
