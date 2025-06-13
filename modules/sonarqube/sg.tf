resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "SG for SonarQube"
  vpc_id = var.vpc_id

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
  security_group_id = aws_security_group.sonarqube_sg.id
  description       = "Allow 80 from Trusted IP"
}

resource "aws_security_group_rule" "allow_jenkins_to_sonar" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.jenkins_master_sg_id
  security_group_id        = aws_security_group.sonarqube_sg.id
  description              = "Allow 80 from Jenkins Master"
}

resource "aws_security_group_rule" "egress_all_sonar" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sonarqube_sg.id
}