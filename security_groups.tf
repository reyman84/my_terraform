#####################
## Security Groups ##
#####################

# --------------------- Security Group - Port 22 only For SSH --------------------- #
# SSH from my IP (For Bastion host, Ansible Controll Machine, Jenkins Master)

/*resource "aws_security_group" "bastion_host" {
  name        = "Bastion_Host"
  description = "Allow SSH connection from Trusted IP"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow SSH from Trusted IP"
    from_port   = local.ports.ssh
    to_port     = local.ports.ssh
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
    Name = "Bastion_Host"
  }
}*/

# --------------------- Security Group - Ansible-host  --------------------- #
# ------------------------ port 22 from bastion host ----------------------- #
# For doing SSH from Ansible Controller Machine to Ansible Hosts

/*resource "aws_security_group" "ssh_from_bastion_host" {
  name        = "SSH_from_bastion_host"
  description = "Allow port 22 from bastion host"
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
    Name = "SSH_from_bastion_host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_22_from_bastion_host" {
  description                  = "Allow SSH from Bastion Host"
  from_port                    = local.ports.ssh
  to_port                      = local.ports.ssh
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_host.id
  security_group_id            = aws_security_group.ssh_from_bastion_host.id

  tags = {
    Name = "Allow SSH from Bastion Host"
  }
}*/

# --------------------- Load Balancer SG - (Only Port 80 from anywhere) --------------------- #

/*resource "aws_security_group" "http" {
  name        = "ALB_SG"
  description = "Allow HTTP from anywhere"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = local.ports.http
    to_port     = local.ports.http
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

# --------------------- Security Group - Jenkins --------------------- #

/**/

# --------------------- Security Group - SonarQube --------------------- #

/*resource "aws_security_group" "sonar_sg" {
  name        = "sonarqube-sg"
  description = "SG for SonarQube"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "sonarqube-sg"
  }
}

resource "aws_security_group_rule" "allow_trusted_to_sonar" {
  type              = "ingress"
  from_port         = local.ports.http
  to_port           = local.ports.http
  protocol          = "tcp"
  cidr_blocks       = [var.trusted_ip]
  security_group_id = aws_security_group.sonar_sg.id
  description       = "Allow 80 from Trusted IP"
}

resource "aws_security_group_rule" "allow_jenkins_to_sonar" {
  type                     = "ingress"
  from_port                = local.ports.http
  to_port                  = local.ports.http
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_master.id
  security_group_id        = aws_security_group.sonar_sg.id
  description              = "Allow 80 from Jenkins Master"
}

resource "aws_security_group_rule" "egress_all_sonar" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sonar_sg.id
}*/

# --------------------- Security Group - Nexus --------------------- #

/*resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "SG for Nexus"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "nexus-sg"
  }
}

resource "aws_security_group_rule" "allow_trusted_to_nexus" {
  type              = "ingress"
  from_port         = local.ports.nexus
  to_port           = local.ports.nexus
  protocol          = "tcp"
  cidr_blocks       = [var.trusted_ip]
  security_group_id = aws_security_group.nexus_sg.id
  description       = "Allow 8081 from Trusted IP"
}

resource "aws_security_group_rule" "egress_all_nexus" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.nexus_sg.id
}

resource "aws_security_group_rule" "allow_jenkins_to_nexus" {
  type                     = "ingress"
  from_port                = local.ports.nexus
  to_port                  = local.ports.nexus
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_master.id
  security_group_id        = aws_security_group.nexus_sg.id
  description              = "Allow 8081 from Jenkins Master"
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
  from_port                    = local.ports.http
  to_port                      = local.ports.http
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.web01.id
  referenced_security_group_id = aws_security_group.http.id

  tags = {
    Name = "Allow HTTP from ALB"
  }
}*/

# --------------------- Allow All Traffic from anywhere --------------------- #

/*resource "aws_security_group" "All_Traffic_enabled" {
  name        = "All_Traffic_Enabled"
  description = "Allow all traffic from anywhere"
  vpc_id = module.vpc.vpc_id

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
}*/