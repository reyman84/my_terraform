resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "SG for Nexus"
  vpc_id      = var.vpc_id

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
  source_security_group_id = var.jenkins_master_sg_id
  security_group_id        = aws_security_group.nexus_sg.id
  description              = "Allow 8081 from Jenkins Master"
}