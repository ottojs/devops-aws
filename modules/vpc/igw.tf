
########################
##### Public - IGW #####
########################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
    App  = var.tag_app
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }
  tags = {
    Name = "rt-${var.name}-public-igw"
    App  = var.tag_app
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table_association" "public" {
  for_each       = { for i, subnet in aws_subnet.public : i => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
