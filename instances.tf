/*resource "aws_instance" "bastion_host" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.linux.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "Bastion-Host"
  }
}*/

/*resource "aws_instance" "docker" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "Docker-Engine"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove -y $pkg || true; done",

      "sudo apt install -y ca-certificates curl gnupg lsb-release",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list",

      "sudo apt update -y",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      "sudo usermod -aG docker ubuntu"
    ]
  }
}*/

/*resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "Jenkins-Slave"
  }
}

resource "aws_ebs_volume" "jenkins_slave_volume" {
  availability_zone = aws_instance.jenkins_slave.availability_zone
  size              = 2
  type              = "gp2"

  tags = {
    Name = "jenkins-slave-tmp"
  }
}

resource "aws_volume_attachment" "jenkins_slave_attachment" {
  device_name  = "/dev/sdf"
  volume_id    = aws_ebs_volume.jenkins_slave_volume.id
  instance_id  = aws_instance.jenkins_slave.id
  force_detach = true
}

resource "null_resource" "jenkins_slave_provision" {
  depends_on = [aws_volume_attachment.jenkins_slave_attachment]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-files/devops_project")
    host        = aws_instance.jenkins_slave.public_ip
  }

  provisioner "file" {
    source      = "scripts/jenkins_slave.sh"
    destination = "/home/ec2-user/jenkins_slave.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /tmp",
      "echo \"/dev/xvdf /tmp ext4 defaults,nofail 0 2\" | sudo tee -a /etc/fstab",

      "sudo yum install -y dos2unix",
      "dos2unix /home/ec2-user/jenkins_slave.sh",
      "sudo bash /home/ec2-user/jenkins_slave.sh"
    ]
  }
}*/

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.jenkins_master.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name


  tags = {
    Name = "Jenkins-Master"
  }

  user_data = <<-EOF
                #!/bin/bash
                set -eux
                
                # Update system
                apt update -y
                apt install -y fontconfig ca-certificates apt-transport-https curl unzip
                
                # Install AWS CLI v2
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                
                # Install Java 21
                apt install -y openjdk-21-jdk
                java -version
                
                # Install Jenkins repo
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
                  -o /etc/apt/keyrings/jenkins-keyring.asc
                
                echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
                
                apt update -y
                apt install -y jenkins
                systemctl stop jenkins
                
                # Download backup (IAM role must be attached!)
                aws s3 cp s3://jenkins-config-terraform/jenkins_configuration.tar.gz /root/jenkins_backup.tar.gz --region us-east-1
                
                # Restore Jenkins config
                tar -xzvf /root/jenkins_backup.tar.gz -C / --overwrite
                chown -R jenkins:jenkins /var/lib/jenkins
                
                systemctl start jenkins
            EOF
}

/*resource "aws_instance" "nexus" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.nexus.id]

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
  }

  tags = {
    Name = "Nexus-Server"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/nexus-setup.sh"
    destination = "/home/ec2-user/nexus-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y dos2unix",
      "dos2unix /home/ec2-user/nexus-setup.sh",
      "sudo bash /home/ec2-user/nexus-setup.sh"
    ]
  }
}*/

/*resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.sonarqube.id]

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
  }

  tags = {
    Name = "SonarQube-Server"
  }

  provisioner "file" {
    source      = "scripts/sonar-setup.sh"
    destination = "/home/ubuntu/sonar-setup.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y dos2unix",
      "dos2unix /home/ubuntu/sonar-setup.sh",
      "sudo bash /home/ubuntu/sonar-setup.sh"
    ]
  }
}*/

/*resource "aws_instance" "ansible_controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "Ansible-Controller"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y software-properties-common
              apt-add-repository --yes --update ppa:ansible/ansible
              apt install -y ansible
            EOF
}*/

/*resource "aws_instance" "ansible_node_ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "ansible-node-ubuntu"
  }
}*/

/*resource "aws_instance" "ansible_node_linux" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "ansible-node-linux"
  }
}*/