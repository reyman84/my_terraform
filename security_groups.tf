#####################
## Security Groups ##
#####################

# --------------------- Security Group for Bastion Host (only Port 22) --------------------- #

resource "aws_security_group" "bastion_host" {
  name        = "Baston_Host"
  description = "Allow SSH connection from Trusted IP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from Trusted IP"
    from_port   = var.ports["ssh"]
    to_port     = var.ports["ssh"]
    protocol    = "tcp"
    cidr_blocks = [var.trusted_ip]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Baston_Host"
  }
}

# --------------------- ALB Security Group (Only Port 80 from anywhere) --------------------- #
resource "aws_security_group" "http" {
  name        = "ALB_SG"
  description = "Allow HTTP from anywhere"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = var.ports["http"]
    to_port     = var.ports["http"]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ALB_SG"
  }
}

# --------------------- Security Group for Jenkins (only Port 8080) --------------------- #
resource "aws_security_group" "jenkins_master" {
  name        = "Port 8080 for Jenkins"
  description = "Allow port 8080 from trusted IP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow 8080 for Jenkins"
    from_port   = var.ports["jenkins"]
    to_port     = var.ports["jenkins"]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Port 8080 for Jenkins"
  }
}

# --------------------- Security Group Web Server --------------------- #
resource "aws_security_group" "web01" {
  name        = "Web_Server"
  description = "Allow HTTP and SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Web_Server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH_from_Baston_Host" {
  description                  = "Allow SSH from Bastion Host"
  from_port                    = var.ports["ssh"]
  to_port                      = var.ports["ssh"]
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_host.id
  security_group_id            = aws_security_group.web01.id

  tags = {
    Name = "Allow SSH from Bastion Host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_from_ALB_SG" {
  description                  = "Allow HTTP from ALB-SG"
  from_port                    = var.ports["http"]
  to_port                      = var.ports["http"]
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.web01.id
  referenced_security_group_id = aws_security_group.http.id

  tags = {
    Name = "Allow HTTP from ALB"
  }
}

# --------------------- Allow All Traffic from anywhere --------------------- #

resource "aws_security_group" "All_Traffic_enabled" {
  name        = "All_Traffic_Enabled"
  description = "Allow all traffic from anywhere"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow all inbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "All - Traffic_Enabled"
  }
}



# --------------------- Security Group Ansible-host (port 22 from bastion host) --------------------- #
resource "aws_security_group" "ansible_host" {
  name        = "ansible_host"
  description = "Allow port 22 from bastion host"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ansible_host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_from_Baston_Host" {
  description                  = "Allow SSH from Bastion Host"
  from_port                    = var.ports["ssh"]
  to_port                      = var.ports["ssh"]
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_host.id
  security_group_id            = aws_security_group.ansible_host.id

  tags = {
    Name = "Allow SSH from Bastion Host"
  }
}