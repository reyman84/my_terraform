# --------------------- Bastion Host ---------------------
/*
resource "aws_instance" "bastion_host" {
  instance_type          = "t2.micro"
  ami                    = var.ami["amazon_linux_2"]
  key_name               = aws_key_pair.bastion_host.id
  subnet_id              = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "Bastion-Host"
  }

  provisioner "file" {
    source      = "key_files/web01"
    destination = "/home/ec2-user/web01"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/web01"
    ]
  }
}*/

# --------------------- Docker & GIT on Amazon-Linux-2 ---------------------
/*
resource "aws_instance" "docker" {
  instance_type = "t2.medium"               # t2-medium is "Chargeable"
  ami           = var.ami["amazon_linux_2"]
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public_subnet_1a.id
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
/*
resource "aws_instance" "web_servers" {
  #for_each      = aws_subnet.private_subnets
  count         = var.unstable_instance_count
  ami           = var.ami["amazon_linux_2"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.web01.id
  subnet_id = element([
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id,
    aws_subnet.public_subnet_1c.id
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
# --------------------- MYSQL / Mariadb ---------------------


/*resource "aws_instance" "manual_roject_sql" {
  instance_type = "t2.micro"
  ami           = var.ami["amazon_linux_2"]
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public_subnet_1a.id

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

# --------------------- Ansible Control Machine on Ubuntu ---------------------

/*resource "aws_instance" "ansible_cm" {
  ami                    = var.ami["ubuntu"]
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ansible.id
  subnet_id              = aws_subnet.public_subnet_1c.id
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key_files/ansible") # This is your PRIVATE key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "key_files/ansible"
    destination = "/home/ubuntu/clientkey"
  }

  #provisioner "file" {
  #  source      = "installation_scripts/inventory"
  #  destination = "/home/ubuntu/inventory"
  #}

  provisioner "file" {
    source      = "installation_scripts/ansible.sh"
    destination = "/home/ubuntu/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y dos2unix",
      "dos2unix /home/ubuntu/ansible.sh",
      "sudo chmod +x /home/ubuntu/ansible.sh",
      "sudo sh /home/ubuntu/ansible.sh",
      "sudo ansible-galaxy collection install amazon.aws --force"
    ]
  }

  tags = {
    Name = "Ansible Control Machine"
  }
}*/

# --------------------- Ansible Host on 2 different AMIs ---------------------

/*locals {
  instances = {
    "Host - Amazon_Linux" = var.ami["amazon_linux_2"]
    "Host - Ubuntu"       = var.ami["ubuntu"]
  }
}

locals {
  subnet_id = {
    "Host - Amazon_Linux" = aws_subnet.public_subnet_1a.id
    "Host - Ubuntu"       = aws_subnet.public_subnet_1b.id
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

# --------------------- Jenkins Master ---------------------

/*resource "aws_instance" "jenkins_master" {
  ami           = var.ami["jenkins_master"] # Basic Jenkins installation
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public_subnet_1c.id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.jenkins_master.id
  ]

  tags = {
    Name = "Jenkins_Master"
  }
}*/

# --------------------- Jenkins Slave ---------------------

/*resource "aws_instance" "jenkins_slave" {
  ami           = var.ami["amazon_linux_2"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public_subnet_1b.id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.ssh_from_bastion_host.id
  ]

  tags = {
    Name = "Jenkins_Slave"
  }
}

# Create an additional EBS volume for "/tmp"
resource "aws_ebs_volume" "jenkins_slave_volume" {
  availability_zone = aws_instance.jenkins_slave.availability_zone
  size              = 2
  type              = "gp2"

  tags = {
    Name = "/tmp - jenkins slave"
  }
}

# 2. Attach the EBS volume to the Jenkins slave instance
resource "aws_volume_attachment" "jenkins_slave_attachment" {
  device_name  = "/dev/sdf"
  volume_id    = aws_ebs_volume.jenkins_slave_volume.id
  instance_id  = aws_instance.jenkins_slave.id
  force_detach = true
}

# Run commands when the volume is attached using remote-exec provisioner
resource "null_resource" "volume_provisioner_slave" {
  depends_on = [aws_volume_attachment.jenkins_slave_attachment]


  provisioner "file" {
    source      = "installation_scripts/jenkins_slave.sh"
    destination = "/home/ec2-user/jenkins_slave.sh"
  }

  provisioner "file" {
    source      = "key_files"
    destination = "/home/ec2-user/key_files"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key_files/bastion-host")
    host        = aws_instance.jenkins_slave.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /tmp",
      "sudo -i -u root bash -c 'echo \"/dev/xvdf  /tmp  ext4  defaults,nofail  0  2\" >> /etc/fstab'",
      "mount -a",
      "df -h /tmp",
      "sudo yum install -y dos2unix",
      "dos2unix /home/ec2-user/jenkins_slave.sh",
      "sudo chmod 755 /home/ec2-user/jenkins_slave.sh",
      "sudo sh /home/ec2-user/jenkins_slave.sh",
      "sudo reboot"
    ]
  }
}*/

# --------------------- Nexus Setup ---------------------

/*resource "aws_instance" "nexus" {
  ami           = var.ami["nexus"] # Nexus Setup on top of Amazon AMI
  instance_type = "t2.medium"
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public_subnet_1b.id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.nexus_sg.id
  ]

  tags = {
    Name = "Nexus"
  }

}

# --------------------- Sonarqube Setup ---------------------

resource "aws_instance" "sonarqube" {
  ami           = var.ami["sonarqube"] # SonarQube Setup on top of Ubuntu AMI
  instance_type = "t2.medium"
  key_name      = aws_key_pair.bastion_host.id
  subnet_id     = aws_subnet.public_subnet_1b.id

  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.sonar_sg.id
  ]

  tags = {
    Name = "Sonarqube Server"
  }
}*/