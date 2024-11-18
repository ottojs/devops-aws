
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  # Instead of creating a route table and specifying it,
  # We re-purpose the default route table (private)
  # main_route_table_id = aws_route_table.public.id

  tags = {
    Name = "vpc-${var.name}"
    APP  = var.tag_app
  }
}
