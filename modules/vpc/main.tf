# VPC Configuration
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "Terraform - VPC"
  }
  lifecycle {
    prevent_destroy = true
  }
}

######################### Public  Resources #########################
# Internet Gateway / Subnet / Route Table / Route Table Association #
#####################################################################

# Internet Gateway
resource "aws_internet_gateway" "igt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Terraform - IGT"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnet

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value
  availability_zone       = var.zone[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${each.key}"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igt.id
  }

  tags = {
    Name = "Public_RT"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# #################### Private  Resources ################### #
# EIP / NAT / Subnets / Route Table / Route Table Association #
# ########################################################### #

#                                 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                                  Caution Don't Launch Private Resources without Permission 
#                                 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

# Elastic IP and NAT Gateway
resource "aws_eip" "eip" {
  tags = { 
    Name = "Terraform - EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public["1a"].id
  allocation_id = aws_eip.eip.allocation_id
  depends_on    = [aws_internet_gateway.igt]
  tags = {
    Name = "Terraform - NAT"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = var.private_subnet

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value
  availability_zone       = var.zone[each.key]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet ${each.key}"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private_RT"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
