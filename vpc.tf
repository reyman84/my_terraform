# VPC
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

resource "aws_internet_gateway" "igt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Terraform - IGT"
  }
}

# Create Public Subnets using for_each
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
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igt.id
  }

  tags = {
    Name = "Public_RT"
  }
}

# Associate all public subnets with the route table
resource "aws_route_table_association" "public_rt_association" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# #################### Private  Resources ################### #
# EIP / NAT / Subnets / Route Table / Route Table Association #
# ########################################################### #

#                                 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                                  Caution Don't Launch Private Resources without Permission 
#                                 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

/*resource "aws_eip" "eip" {
  tags = { Name = "Terraform - EIP" }
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public["1a"].id
  allocation_id = aws_eip.eip.allocation_id
  depends_on    = [aws_internet_gateway.igt]
  tags = {
    Name = "Terraform - NAT"
  }
}

# Create Private Subnets using for_each
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
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private_RT"
  }
}

# Associate all private subnets with the route table
resource "aws_route_table_association" "private_rt_association" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}*/

###############
## Key-Pairs ##
###############

resource "aws_key_pair" "bastion_host" {
  key_name   = "bastion-host"
  public_key = file("key_files/bastion-host.pub")
}

/*resource "aws_key_pair" "web01" {
  key_name   = "web-host"
  public_key = file("key_files/web01.pub")
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = file("key_files/ansible.pub")
}

resource "aws_key_pair" "jenkins_master" {
  key_name   = "jenkins_master"
  public_key = file("key_files/jenkins_master.pub")
}

resource "aws_key_pair" "jenkins_slave" {
  key_name   = "jenkins_slave"
  public_key = file("key_files/jenkins_slave.pub")
}*/