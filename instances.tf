# -------------------------------------------------------------------------
# Resource  : Docker Engine Server
# Purpose   : Provision a Docker Engine server with Docker CE, Buildx,
#             and Docker Compose plugin installed through remote-exec.
# OS        : Ubuntu
# -------------------------------------------------------------------------

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

# -------------------------------------------------------------------------
# Resource  : Ansible Controller Server
# Purpose   : Launch an Ansible Controller server with Ansible installed
#             via user_data using PPA repository.
# OS        : Ubuntu
# Requires  : SSH connection from Controller to Target Nodes
# -------------------------------------------------------------------------

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

# -------------------------------------------------------------------------
# Resource  : Ansuble Target Node - "Ubuntu"
# Purpose   : Target node for testing multi-platform automation.
# OS        : Ubuntu
# Requires  : SSH connection from Controller to Target Nodes
# -------------------------------------------------------------------------

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

# -------------------------------------------------------------------------
# Resource  : Ansible Target Node - "Amazon Linux"
# Purpose   : Target node for testing multi-platform automation.
# OS        : Amazon Linux
# Requires  : SSH connection from Controller to Target Nodes
# -------------------------------------------------------------------------

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

# -------------------------------------------------------------------------
# Resource  : Jenkins Master Server
# Purpose:
#   - Install Jenkins, Java 21, AWS CLI
#   - Restore Jenkins configuration from S3 bucket using IAM role
# OS        : Ubuntu
# Requires  : SSH connection between Jenkins Master and Slave nodes
# -------------------------------------------------------------------------

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

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  provisioner "file" {
    source      = "scripts/jenkins_master.sh"
    destination = "/home/ubuntu/jenkins_master.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops_project")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "until sudo apt update -y; do sleep 5; done",
      "sudo apt install -y dos2unix",
      "dos2unix /home/ubuntu/jenkins_master.sh",
      "sudo bash /home/ubuntu/jenkins_master.sh > /var/log/jenkins_master_setup.log 2>&1"
    ]
  }
}

# -------------------------------------------------------------------------
# Component : Jenkins Slave (Build Agent)
# Purpose   : Provisions Jenkins Build Agent node 
# OS        : Amazon Linux
# Requires  : SSH connection between Jenkins Master and Slave nodes
# -------------------------------------------------------------------------

resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.jenkins_master.id]

  tags = {
    Name = "Jenkins-Slave"
  }

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

resource "aws_ebs_volume" "jenkins_slave_volume" {
  availability_zone = aws_instance.jenkins_slave.availability_zone
  size              = 2
  type              = "gp3"

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

  provisioner "file" {
    source      = "scripts/jenkins_slave.sh"
    destination = "/home/ubuntu/jenkins_slave.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key-files/devops_project")
    host        = aws_instance.jenkins_slave.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mkdir -p /tmp",
      "sudo mount /dev/xvdf /tmp",
      "echo '/dev/xvdf /tmp ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo chown ubuntu:ubuntu /tmp",
      "chmod 1777 /tmp",

      "sleep 30",
      "until sudo apt update -y; do sleep 5; done",
      "sudo apt install -y dos2unix",
      "dos2unix /home/ubuntu/jenkins_slave.sh",
      "sudo bash /home/ubuntu/jenkins_slave.sh > /var/log/jenkins_slave_setup.log 2>&1"
    ]
  }
}

# -------------------------------------------------------------------------
# Resource  : Nexus Repository Manager Server
# Purpose   : Provision Nexus Repository Manager (Sonatype) using 
#             remote-exec with a custom setup script.
# OS        : Amazon Linux
# -------------------------------------------------------------------------

resource "aws_instance" "nexus" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.nexus.id]
  #iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    delete_on_termination = true
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
      "sudo bash /home/ec2-user/nexus-setup.sh > /var/log/nexus_setup.log 2>&1"
    ]
  }
}

# -------------------------------------------------------------------------
# Resource  : SonarQube Server
# Purpose   : Install and configure SonarQube using a custom shell script.
# OS        : Ubuntu
# -------------------------------------------------------------------------

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.sonarqube.id]

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    delete_on_termination = true
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
      "sudo bash /home/ubuntu/sonar-setup.sh > /var/log/sonar_setup.log 2>&1"
    ]
  }
}

# -------------------------------------------------------------------------
# Resource  : Jenkins Ansible Deployment Nodes
# Purpose   : - Creates two nodes (Stage & Prod) for deployment automation.
#             - Used by Jenkins for Deployment pipelines.
# OS        : Ubuntu
# -------------------------------------------------------------------------

# Create two Jenkins Ansible deployment nodes for stage and prod environments
/*resource "aws_instance" "jenkins_ansible_deployment" {
  count = 2
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "ansible_nodes-${count.index + 1}"
  }
}*/