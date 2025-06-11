
########################
##### Public - IGW #####
########################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "public" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }
  tags = merge(var.tags, {
    Name = "rt-${var.name}-public-igw"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table_association" "public" {
  for_each       = var.enable_igw ? { for i, subnet in aws_subnet.public : i => subnet } : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}
