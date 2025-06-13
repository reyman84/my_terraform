# For doing SSH from Ansible Controller Machine to Ansible Hosts

resource "aws_security_group" "ssh_from_bastion_host" {
  name        = "SSH_from_bastion_host"
  description = "Allow port 22 from bastion host"
  vpc_id      = var.vpc_id

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
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.bastion_sg_id
  security_group_id            = aws_security_group.ssh_from_bastion_host.id

  tags = {
    Name = "Allow SSH from Bastion Host"
  }
}

# Key-Pair
resource "aws_key_pair" "jenkins_slave" {
  key_name   = "jenkins_slave"
  public_key = file("key_files/jenkins_slave.pub")
}