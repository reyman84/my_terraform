#####################
## Security Groups ##
#####################

# --------------------- Security Group for Port 22 --------------------- #
# SSH from my IP (For Bastion host, Ansible Controll Machine, Jenkins Master)

resource "aws_security_group" "bastion_host" {
  name        = "Baston_Host"
  description = "Allow SSH connection from Trusted IP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from Trusted IP"
    from_port   = 22
    to_port     = 22
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

# --------------------- Security Group Ansible-host (port 22 from bastion host) --------------------- #
# To do SSH from Bastion Host (For Ansible Host, Jenkins Slave)

resource "aws_security_group" "ssh_from_bastion_host" {
  name        = "Ansible host - ssh_from_bastion_host"
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
    Name = "Ansible host - ssh_from_bastion_host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_from_Baston_Host" {
  description                  = "Allow SSH from Bastion Host"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_host.id
  security_group_id            = aws_security_group.ssh_from_bastion_host.id

  tags = {
    Name = "Allow SSH from Bastion Host"
  }
}

# --------------------- ALB Security Group (Only Port 80 from anywhere) --------------------- #

resource "aws_security_group" "http" {
  name        = "ALB_SG"
  description = "Allow HTTP from anywhere"
  vpc_id      = aws_vpc.vpc.id

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
}

# --------------------- Security Group for Jenkins (only Port 8080) --------------------- #

resource "aws_security_group" "jenkins_master" {
  name        = "Jenkins Master - Port 8080"
  description = "Allow port 8080 from trusted IP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow 8080 for Jenkins"
    from_port   = 8080
    to_port     = 8080
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
    Name = "Jenkins Master - Port 8080"
  }
}

# --------------------- Security Group for Nexus (Port 8081) --------------------- #

resource "aws_security_group" "nexus" {
  name        = "nexus-sg"
  description = "Security Group for Nexus Repository"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow 8081 from trusted IP"
    from_port   = 8081
    to_port     = 8081
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
    Name = "Nexus Security Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nexus_allow_from_jenkins" {
  description                  = "Allow 8081 from Jenkins Master Security Group"
  security_group_id            = aws_security_group.nexus.id
  referenced_security_group_id = aws_security_group.jenkins_master.id
  from_port                    = 8081
  to_port                      = 8081
  ip_protocol                  = "tcp"

  tags = {
    Name = "Nexus access from Jenkins SG"
  }

  depends_on = [
    aws_security_group.nexus,
    aws_security_group.jenkins_master
  ]
}

# --------------------- Security Group for SonarQube (Port 80) --------------------- #

resource "aws_security_group" "sonar-sg" {
  name        = "Sonar SG"
  description = "Port 80"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from Trusted IP"
    from_port   = 22
    to_port     = 22
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
    Name = "Sonar SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_from_Jenkins_Master" {
  description                  = "Allow HTTP from Jenkins_master"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.sonar-sg.id
  referenced_security_group_id = aws_security_group.jenkins_master.id

  tags = {
    Name = "Allow 80 from Jenkins Master"
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
  from_port                    = 22
  to_port                      = 22
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