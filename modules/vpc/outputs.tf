output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "Map of AZ keys to public subnet IDs"
  value = {
    for k, subnet in aws_subnet.public :
    k => subnet.id
  }
}

# Private Subnets
/*output "private_subnet_ids" {
  description = "Map of private subnet IDs"
  value = [for subnet in aws_subnet.private : subnet.id]
}*/
