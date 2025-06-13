# --------------------- Docker Engine & Docker Compose ---------------------
# --------------------------- on Amazon-Linux-2 ----------------------------

/*resource "aws_instance" "docker" {
  instance_type = "t2.medium"               # t2-medium is "Chargeable"
  ami           = data.aws_ami.linux.id
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public["1a"].id
  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.http.id
  ]

  tags = {
    Name = "Docker"
  }

  provisioner "file" {
    source      = "installation_scripts/docker.sh"
    destination = "/home/ec2-user/docker.sh"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo yum install -y dos2unix",
      "dos2unix /home/ec2-user/docker.sh",
      "sudo chmod +x /home/ec2-user/docker.sh",
      "sudo sh /home/ec2-user/docker.sh"
    ]
  }
}*/

# --------------------- Web Server ---------------------
/* resource "aws_instance" "web_servers" {
  #for_each      = aws_subnet.private_subnets
  count         = var.instance_count.unstable
  ami           = data.aws_ami.linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.web01.id
  subnet_id = element([
    aws_subnet.public["1a"].id,
    aws_subnet.public["1b"].id,
    aws_subnet.public["1"].id
  ], count.index)

  # This security group should all traffic on port 80
  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.http.id
  ]

  tags = {
    Name = "WebServer-${count.index + 1}"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum install wget unzip httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                wget https://www.tooplate.com/zip-templates/2117_infinite_loop.zip
                unzip -o 2117_infinite_loop.zip
                cp -r 2117_infinite_loop /var/www/html/
                sudo systemctl restart httpd
                EOF
}*/

# --------------------- Manual-Project ---------------------
# --------------------- MYSQL/ Mariadb ---------------------

/*resource "aws_instance" "manual_project_sql" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.linux.id
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public["1a"].id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.http.id
  ]

  tags = {
    Name = "Manual_Project_SQL"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Installing MariaDB and GIT
      "sudo dnf install -y git mariadb105-server",
      "sudo systemctl start mariadb",
      "sudo systemctl enable mariadb",
      "mysql --version",
      #"sudo systemctl status mariadb",
      "cd /tmp",
      "git clone -b local https://github.com/hkhcoder/vprofile-project.git"
    ]
  }
}*/

# --------------------- Ansible Host on 2 different AMIs ---------------------

/*locals {
  instances = {
    "Host - Amazon_Linux" = data.aws_ami.linux.id
    "Host - Ubuntu"       = data.aws_ami.ubuntu.id
  }
}

locals {
  subnet_id = {
    "Host - Amazon_Linux" = aws_subnet.public["1a"].id
    "Host - Ubuntu"       = aws_subnet.public["1b"].id
  }
}

resource "aws_instance" "ansible_hosts" {
  for_each = local.instances
  ami      = each.value

  instance_type = "t2.micro"
  key_name      = aws_key_pair.ansible.id

  subnet_id = local.subnet_id[each.key]

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.ssh_from_bastion_host.id,
    aws_security_group.All_Traffic_enabled.id
  ]

  tags = {
    Name = each.key
  }
}*/

# --------------------- Nexus Setup ---------------------
# ---------------- on top of Amazon AMI -----------------

/*resource "aws_instance" "nexus" {
  ami           = var.ami["nexus"]
  instance_type = "t2.medium"
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public["1c"].id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.nexus_sg.id
  ]

  tags = {
    Name = "Nexus"
  }

}*/

# --------------------- Sonarqube Setup ---------------------
# ------------------ on top of Ubuntu AMI -------------------

/*resource "aws_instance" "sonarqube" {
  ami           = var.ami["sonarqube"] 
  instance_type = "t2.medium"
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public["1b"].id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.sonar_sg.id
  ]

  tags = {
    Name = "Sonarqube Server"
  }
}*/