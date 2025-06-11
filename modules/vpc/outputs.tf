
output "vpc" {
  value = aws_vpc.main
}

output "security_group" {
  value = aws_security_group.main
}

output "subnets_private" {
  value = [for i, subnet in var.subnets_private : aws_subnet.private[i]]
}

output "subnets_private_ids" {
  value = [for i, subnet in var.subnets_private : aws_subnet.private[i].id]
}

output "subnets_public" {
  value = [for i, subnet in var.subnets_public : aws_subnet.public[i]]
}

output "subnets_public_ids" {
  value = [for i, subnet in var.subnets_public : aws_subnet.public[i].id]
}

output "nat_ip" {
  value = var.enable_nat ? aws_eip.nat[0] : null
}
