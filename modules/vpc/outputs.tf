output "vpc_id" {
  value = aws_vpc.vpc.id
}

# Public Subnets
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

# Private Subnets
/*output "private_subnet_ids" {
  description = "Map of private subnet IDs"
  value = [for subnet in aws_subnet.private : subnet.id]
}*/
