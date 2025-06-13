output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs"
  value = {
    for k, subnet in aws_subnet.public : k => subnet.id
  }
}