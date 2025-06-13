#####################
## Security Groups ##
#####################

# --------------------- Load Balancer SG - (Only Port 80 from anywhere) --------------------- #

/*resource "aws_security_group" "http" {
  name        = "ALB_SG"
  description = "Allow HTTP from anywhere"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
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
}*/

# --------------------- Security Group - Web Server --------------------- #

/*resource "aws_security_group" "web01" {
  name        = "Web_Server"
  description = "Allow HTTP and SSH inbound traffic and all outbound traffic"
  vpc_id = module.vpc.vpc_id

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

resource "aws_vpc_security_group_ingress_rule" "allow_SSH_from_bastion_host" {
  description                  = "Allow SSH from Bastion Host"
  from_port                    = local.ports.ssh
  to_port                      = local.ports.ssh
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_host.id
  security_group_id            = aws_security_group.web01.id

  tags = {
    Name = "Allow SSH from Bastion Host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_from_ALB_SG" {
  description                  = "Allow HTTP from ALB-SG"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.web01.id
  referenced_security_group_id = aws_security_group.http.id

  tags = {
    Name = "Allow HTTP from ALB"
  }
}*/