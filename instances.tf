# --------------------- Baston Host ---------------------

/*resource "aws_instance" "bastion_host" {
  #count                  = 2
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.linux.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "Bastion-Host"
    #Name = "vprofile-web0${count.index + 1}"

  }
}*/

# --------------------- Docker on Ubuntu ---------------------

/*resource "aws_instance" "docker" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "Docker Engine"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Remove older versions
      "for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg || true; done",

      # Add Docker's official GPG key
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      # Add the repository to Apt sources
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Install Docker
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo systemctl enable docker",

      # Add ubuntu user to docker group
      "sudo usermod -aG docker ubuntu"
    ]
  }
}*/

# --------------------- Jenkins Slave ---------------------

/*resource "aws_instance" "jenkins_slave" {
  ami = data.aws_ami.linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.devops_project.key_name
  subnet_id     = module.vpc.public_subnets[1]

  vpc_security_group_ids = [ aws_security_group.bastion_host.id ]

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
    private_key = file("key-files/devops_project")
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
  key_name      = aws_key_pair.devops_project.key_name
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
    private_key = file("key-files/devops_project")
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
}*/

# --------------------- Nexus Setup ---------------------

/*resource "aws_instance" "nexus" {
  ami           = data.aws_ami.linux.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops_project.key_name
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
    private_key = file("key-files/devops_project")
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
}*/

# --------------------- Sonarqube Setup ---------------------

/*resource "aws_instance" "sonarqube" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops_project.key_name
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
    private_key = file("key-files/devops_project")
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

# --------------------- Ansible Control Machine on Ubuntu ---------------------

resource "aws_instance" "ansible_controller_ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ansible.id
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "Controller"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y software-properties-common
              apt-add-repository --yes --update ppa:ansible/ansible
              apt-get install -y ansible
          EOF

# --------------------------------------------------------------------------
# Provisioners for Ansible Control Machine and Remote Hosts
# --------------------------------------------------------------------------
# These provisioners can automate the installation and setup of Ansible on 
# the control machine.
#
# For personal practice, we are leaving them commented out so that we can
# manually install Ansible, configure SSH keys, and understand each step
# of the setup process.
#
# Later, you can uncomment them if you want to try automated provisioning.
# --------------------------------------------------------------------------

/*  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/ansible")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "ansible_files"
    destination = "/tmp/ansible_files"
  }

  provisioner "remote-exec" {
    inline = [      
      # Create devops user and setup Ansible repo
      # 1. Ensure devops user exists
      "sudo useradd -m -s /bin/bash devops || true",
      "echo 'devops ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/devops",
      "sudo chmod 440 /etc/sudoers.d/devops",

      # 2. Create .ssh directory with correct perms
      "sudo mkdir -p /home/devops/.ssh",
      "sudo chmod 700 /home/devops/.ssh",
      "sudo chown devops:devops /home/devops/.ssh",

      # 3. Copy public key into authorized_keys
      "sudo cp -pr /tmp/ansible_files/id_ed25519* /home/devops/.ssh/",
      "sudo chmod 600 /home/devops/.ssh/id_ed25519",
      "sudo chmod 644 /home/devops/.ssh/id_ed25519.pub",
      "sudo chown -R devops:devops /home/devops/.ssh",

      # 4. Enable password authentication (if needed) and restart ssh
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sudo systemctl restart ssh || sudo systemctl restart sshd",

      # 5. (optional) set hostname
      "sudo hostnamectl set-hostname controller",

      # 6. Setup Ansible repo / inventory / logfile
      "sudo mkdir -p /home/devops/ansible-repo",
      "sudo mv /tmp/ansible_files/inventory /home/devops/ansible-repo/inventory",
      "sudo mv /tmp/ansible_files/ansible.cfg /home/devops/ansible-repo/ansible.cfg",
      "sudo chown -R devops:devops /home/devops/ansible-repo",
      "sudo chmod 644 /home/devops/ansible-repo/ansible.cfg",
      "sudo touch /var/log/ansible.log",
      "sudo chown devops:devops /var/log/ansible.log"
    ]
  }*/
}

# --------------------- Ansible Remote host - Ubuntu ---------------------

resource "aws_instance" "ansible_node_ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "ansible_node_ubuntu"
  }

  /*connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "ansible_files"
    destination = "/tmp/ansible_files"
  }

  provisioner "remote-exec" {
    inline = [
      # 1. Ensure devops user exists
      "sudo useradd -m -s /bin/bash devops || true",
      "echo 'devops ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/devops",
      "sudo chmod 440 /etc/sudoers.d/devops",

      # 2. Create .ssh directory with correct perms
      "sudo mkdir -p /home/devops/.ssh",
      "sudo chmod 700 /home/devops/.ssh",
      "sudo chown devops:devops /home/devops/.ssh",

      # 3. Copy public key into authorized_keys
      "sudo cp /tmp/ansible_files/id_ed25519.pub /home/devops/.ssh/authorized_keys",
      "sudo chmod 600 /home/devops/.ssh/authorized_keys",
      "sudo chown devops:devops /home/devops/.ssh/authorized_keys",

      # 4. Enable password authentication (if needed) and restart ssh
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sudo systemctl restart ssh",

      # 5. (optional) set hostname
      "sudo hostnamectl set-hostname ansible-ubuntu"
    ]
  }*/
}

# --------------------- Ansible Remote host - Amazon Linux ---------------------

resource "aws_instance" "ansible_host_linux" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  tags = {
    Name = "ansible_node_Linux"
  }

  /*connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "ansible_files"
    destination = "/tmp/ansible_files"
  }

  provisioner "remote-exec" {
    inline = [
      # 1. Ensure devops user exists
      "sudo useradd -m -s /bin/bash devops || true",
      "echo 'devops ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/devops",
      "sudo chmod 440 /etc/sudoers.d/devops",

      # 2. Create .ssh directory with correct perms
      "sudo mkdir -p /home/devops/.ssh",
      "sudo chmod 700 /home/devops/.ssh",
      "sudo chown devops:devops /home/devops/.ssh",

      # 3. Copy public key into authorized_keys
      "sudo cp /tmp/ansible_files/id_ed25519.pub /home/devops/.ssh/authorized_keys",
      "sudo chmod 600 /home/devops/.ssh/authorized_keys",
      "sudo chown devops:devops /home/devops/.ssh/authorized_keys",

      # 4. Enable password authentication (if needed) and restart ssh
      "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sudo systemctl restart sshd",

      # 5. (optional) set hostname
      "sudo hostnamectl set-hostname ansible-linux",

      # Install "vim" editor
      "sudo yum install -y vim"
    ]
  }*/
}