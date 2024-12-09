
#########################
##### Private - NAT #####
#########################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-nat-ip"
    App  = var.tag_app
  }
  depends_on = [aws_internet_gateway.igw]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id     = aws_eip.nat.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[0].id
  tags = {
    Name = "${var.name}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Instead of creating a Private-NAT Route Table we re-use the default
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table
resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }
  tags = {
    Name = "rt-${var.name}-private-nat"
    App  = var.tag_app
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table_association" "private" {
  for_each       = { for i, subnet in aws_subnet.private : i => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_default_route_table.private.id
}
