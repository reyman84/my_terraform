resource "aws_security_group" "jenkins_master" {
  name        = "jenkins-master-sg"
  description = "SG for Jenkins Master"
  vpc_id = var.vpc_id

  tags = {
    Name = "jenkins-master-sg"
  }
}

resource "aws_security_group_rule" "allow_trusted_to_jenkins" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.trusted_ip]
  security_group_id = aws_security_group.jenkins_master.id
  description       = "Allow 8080 from Trusted IP"
}

/*resource "aws_security_group_rule" "allow_sonar_to_jenkins" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sonar_sg.id
  security_group_id        = aws_security_group.jenkins_master.id
  description              = "Allow 8080 from SonarQube"
}*/

resource "aws_security_group_rule" "egress_all_jenkins" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.jenkins_master.id
}

# Key-Pair
resource "aws_key_pair" "jenkins_master" {
  key_name   = "jenkins_master"
  public_key = file("key_files/jenkins_master.pub")
}