# --------------------- Security Group - Port 22 only For SSH --------------------- #
# SSH from my IP (For Bastion host, Ansible Controll Machine, Jenkins Master)

resource "aws_security_group" "bastion_host" {
  name        = "Bastion_Host"
  description = "Allow SSH connection from Trusted IP"
  vpc_id = var.vpc_id

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
    Name = "Bastion_Host"
  }
}


# Key-Pairs
resource "aws_key_pair" "bastion_host" {
  key_name   = "bastion-host"
  public_key = file("key_files/bastion-host.pub")
}

/*resource "aws_key_pair" "web01" {
  key_name   = "web-host"
  public_key = file("key_files/web01.pub")
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = file("key_files/ansible.pub")
}

resource "aws_key_pair" "jenkins_master" {
  key_name   = "jenkins_master"
  public_key = file("key_files/jenkins_master.pub")
}

resource "aws_key_pair" "jenkins_slave" {
  key_name   = "jenkins_slave"
  public_key = file("key_files/jenkins_slave.pub")
}*/
