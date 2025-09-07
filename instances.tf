# --------------------- Baston Host ---------------------

resource "aws_instance" "bastion_host" {
  count                  = 2
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.linux.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "vprofile-web0${count.index + 1}"
  }
}

# --------------------- Docker & GIT on Amazon-Linux-2 ---------------------
/*
resource "aws_instance" "docker" {
  instance_type = "t2.medium"               # t2-medium is "Chargeable"
  ami           = var.ami["amazon_linux_2"]
  key_name      = aws_key_pair.devops-project.id
  subnet_id     = module.vpc.public_subnets[1]
  vpc_security_group_ids = [
    aws_security_group.bastion_host.id,
    aws_security_group.http.id
  ]

  tags = {
    Name = "Docker"
  }

  provisioner "file" {
    source      = "scripts/docker.sh"
    destination = "/home/ec2-user/docker.sh"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-files/devops-project")
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

# --------------------- Ansible Control Machine on Ubuntu ---------------------

resource "aws_instance" "ansible_cm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ansible.id
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "Controller"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/ansible")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y > /dev/null",
      "sudo apt-get install -y software-properties-common > /dev/null",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible > /dev/null",
      "sudo apt-get install -y ansible > /dev/null",
      "ansible --version"
    ]
  }
}

resource "aws_instance" "ansible_ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.id
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "vprofile-db01"
  }
}

# --------------------- Ansible Host on 2 different AMIs ---------------------

/*locals {
  instances = {
    "Amazon_Linux-Ansible" = var.ami["amazon_linux_2"]
    "Ubuntu-Ansible"       = var.ami["ubuntu"]
  }
}

locals {
  subnet_id = {
    "Amazon_Linux-Ansible" = module.vpc.public_subnets[1]
    "Ubuntu-Ansible"       = module.vpc.public_subnets[2]
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

# --------------------- Jenkins Slave ---------------------

/*resource "aws_instance" "jenkins_slave" {
  ami           = var.ami["amazon_linux_2"]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.devops-project.id
  subnet_id     = module.vpc.public_subnets[1]

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
    source      = "scripts/jenkins_slave.sh"
    destination = "/home/ec2-user/jenkins_slave.sh"
  }

  provisioner "file" {
    source      = "key-files"
    destination = "/home/ec2-user/key-files"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-files/devops-project")
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

# --------------------- Jenkins Master ---------------------

/*resource "aws_instance" "jenkins_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"
  key_name      = aws_key_pair.devops-project.id
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [ aws_security_group.jenkins_master.id]

  root_block_device {
    volume_size           = 15
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "Jenkins_Master"
  }

  provisioner "file" {
    source      = "scripts/jenkins_master.sh"
    destination = "/home/ubuntu/jenkins_master.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops-project")
    host        = aws_instance.jenkins_master.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y dos2unix",
      "dos2unix /home/ubuntu/jenkins_master.sh",
      "sudo chmod 755 /home/ubuntu/jenkins_master.sh",
      "sudo sh /home/ubuntu/jenkins_master.sh",
      "sudo reboot"
    ]
  }
}

# --------------------- Nexus Setup ---------------------

resource "aws_instance" "nexus" {
  ami           = data.aws_ami.linux.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops-project.id
  subnet_id     = module.vpc.public_subnets[1]

  vpc_security_group_ids = [
    #aws_security_group.bastion_host.id,
    aws_security_group.nexus_sg.id
  ]

  tags = {
    Name = "Nexus Server"
  }

  provisioner "file" {
    source      = "scripts/nexus-setup.sh"
    destination = "/home/ec2-user/nexus-setup.sh"
  }

  #provisioner "file" {
  #  source      = "key-files"
  #  destination = "/home/ec2-user/key-files"
  #}

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-files/devops-project")
    host        = aws_instance.nexus.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y dos2unix",
      "sudo dos2unix /home/ec2-user/nexus-setup.sh",
      "sudo chmod 755 /home/ec2-user/nexus-setup.sh",
      "sudo sh /home/ec2-user/nexus-setup.sh",
      "sudo reboot"
    ]
  }
}

# --------------------- Sonarqube Setup ---------------------

resource "aws_instance" "sonarqube" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops-project.id
  subnet_id     = module.vpc.public_subnets[2]

  vpc_security_group_ids = [
    #aws_security_group.bastion_host.id
    aws_security_group.sonarqube_sg.id
  ]

  tags = {
    Name = "sonarqube Server"
  }

  provisioner "file" {
    source      = "scripts/sonar-setup.sh"
    destination = "/home/ubuntu/sonar-setup.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops-project")
    host        = aws_instance.sonarqube.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y dos2unix",
      "sudo dos2unix /home/ubuntu/sonar-setup.sh",
      "sudo chmod 755 /home/ubuntu/sonar-setup.sh",
      "sudo sh /home/ubuntu/sonar-setup.sh" #,
      #"sudo reboot"
    ]
  }
}*/