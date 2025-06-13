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
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.trusted_ip]
  security_group_id = aws_security_group.sonar_sg.id
  description       = "Allow 80 from Trusted IP"
}

resource "aws_security_group_rule" "allow_jenkins_to_sonar" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
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
  from_port         = 8081
  to_port           = 8081
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
  from_port                = 8081
  to_port                  = 8081
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
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.web01.id
  referenced_security_group_id = aws_security_group.http.id

  tags = {
    Name = "Allow HTTP from ALB"
  }
}*/

# --------------------- Allow All Traffic from anywhere --------------------- #

/**/