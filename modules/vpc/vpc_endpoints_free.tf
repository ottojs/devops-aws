
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "gateways" {
  for_each          = toset(["s3", "dynamodb"])
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    var.enable_nat ? [aws_default_route_table.private[0].id] : [],
    var.enable_igw ? [aws_route_table.public[0].id] : []
  )
  tags = merge(var.tags, {
    Name = "vpce-${var.name}-${each.value}"
  })
}
