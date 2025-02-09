
output "vpc" {
  value = aws_vpc.main
}

output "security_group" {
  value = aws_security_group.main
}

output "subnets_private" {
  value = values(aws_subnet.private)[*]
}

output "subnets_public" {
  value = values(aws_subnet.public)[*]
}
