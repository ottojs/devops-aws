
###################
##### Subnets #####
###################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  for_each                = { for i, subnet in var.subnets_public : i => subnet }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = "${var.region}${each.value.az}"
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name   = "subnet-${var.name}-public-${each.value.az}-${each.value.name}"
    Public = true
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private" {
  for_each                = { for i, subnet in var.subnets_private : i => subnet }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = "${var.region}${each.value.az}"
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name   = "subnet-${var.name}-private-${each.value.az}-${each.value.name}"
    Public = false
  })
}
