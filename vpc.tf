# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "Terraform - VPC"
  }
}

######################## Public  Resources ##########################
# Internet Gateway / Subnet / Route Table / Route Table Association #
#####################################################################

resource "aws_internet_gateway" "igt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Terraform - IGT"
  }
}

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet["1a"]
  availability_zone       = var.zone["1a"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1a"
  }
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet["1b"]
  availability_zone       = var.zone["1b"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1b"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet["1c"]
  availability_zone       = var.zone["1c"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1c"
  }
}

/*resource "aws_subnet" "public_subnet_1d" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet["1d"]
  availability_zone       = var.zone["1d"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1d"
  }
}

resource "aws_subnet" "public_subnet_1e" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet["1e"]
  availability_zone       = var.zone["1e"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1e"
  }
}

resource "aws_subnet" "public_subnet_1f" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet["1f"]
  availability_zone       = var.zone["1f"]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1f"
  }
}*/

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    gateway_id = aws_internet_gateway.igt.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "Terraform - Public_RT"
  }
}

resource "aws_route_table_association" "public_rt_asso_1" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_asso_2" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_asso_3" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_rt.id
}

/*resource "aws_route_table_association" "public_rt_asso_4" {
  subnet_id      = aws_subnet.public_subnet_1d.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_asso_5" {
  subnet_id      = aws_subnet.public_subnet_1e.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_asso_6" {
  subnet_id      = aws_subnet.public_subnet_1f.id
  route_table_id = aws_route_table.public_rt.id
}*/

# #################### Private  Resources ################### #
# EIP / NAT / Subnets / Route Table / Route Table Association #
# ########################################################### #

                                   # $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #
                                   #  Caution Don't Launch Private Resources without Permission #
                                   # $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #

/*resource "aws_eip" "eip" {
  tags = { Name = "Terraform - EIP" }
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_subnet_1a.id
  allocation_id = aws_eip.eip.allocation_id
  depends_on    = [aws_internet_gateway.igt]
  tags = {
    Name = "Terraform - NAT"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet["1a"]
  availability_zone       = var.zone["1a"]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet["1b"]
  availability_zone       = var.zone["1b"]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 1b"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet["1c"]
  availability_zone       = var.zone["1c"]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 1c"
  }
}

resource "aws_subnet" "private_subnet_1d" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet["1d"]
  availability_zone       = var.zone["1d"]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 1d"
  }
}

resource "aws_subnet" "private_subnet_1e" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet["1e"]
  availability_zone       = var.zone["1e"]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 1e"
  }
}

resource "aws_subnet" "private_subnet_1f" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet["1f"]
  availability_zone       = var.zone["1f"]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet 1f"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  #route {
  #  gateway_id = aws_nat_gateway.nat.id
  #  cidr_block = "0.0.0.0/0"
  #}
  tags = {
    Name = "Terraform - Private_RT"
  }
}

resource "aws_route_table_association" "private_rt_asso_1" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_asso_2" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_asso_3" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_asso_4" {
  subnet_id      = aws_subnet.private_subnet_1d.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_asso_5" {
  subnet_id      = aws_subnet.private_subnet_1e.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_asso_6" {
  subnet_id      = aws_subnet.private_subnet_1f.id
  route_table_id = aws_route_table.private_rt.id
}*/

###############
## Key-Pairs ##
###############

# --------------------- Bastion Host --------------------- #
resource "aws_key_pair" "bastion_host" {
  key_name   = "bastion-host"
  public_key = file("key_files/bastion-host.pub")
}

# --------------------- Web Server --------------------- #
resource "aws_key_pair" "web01" {
  key_name   = "web-host"
  public_key = file("key_files/web01.pub")
}

# --------------------- Ansible --------------------- #
resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = file("key_files/ansible.pub")
}