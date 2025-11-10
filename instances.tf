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

/*resource "aws_instance" "jenkins_master" {
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

  user_data = <<-EOF
              #!/bin/bash
              set -eux

              export PATH=$PATH:/usr/local/bin:/usr/bin:/bin

              # Install prerequisites
              until apt-get update -y; do sleep 5; done
              apt-get install -y curl unzip ca-certificates > /dev/null

              # Install AWS CLI v2
              curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
              unzip -q /tmp/awscliv2.zip -d /tmp/
              /tmp/aws/install --update
              rm -rf /tmp/aws /tmp/awscliv2.zip

              # Download jenkins_master.sh from S3
              aws s3 cp s3://jenkins-config-terraform/jenkins_master.sh /root/jenkins_master.sh --region us-east-1

              chmod +x /root/jenkins_master.sh
              apt-get install -y dos2unix > /dev/null
              dos2unix /root/jenkins_master.sh

              bash /root/jenkins_master.sh > /var/log/jenkins_master_setup.log 2>&1
          EOF
}*/

# -------------------------------------------------------------------------
# Component : Jenkins Slave (Build Agent)
# Purpose   : Provisions Jenkins Build Agent node 
# OS        : Amazon Linux
# Requires  : SSH connection between Jenkins Master and Slave nodes
# -------------------------------------------------------------------------

/*resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.jenkins_master.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name

  tags = {
    Name = "Jenkins-Slave"
  }

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 2
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -eux

              export PATH=$PATH:/usr/local/bin:/usr/bin:/bin

              # Install prerequisites
              until apt-get update -y; do sleep 5; done
              apt-get install -y curl unzip ca-certificates > /dev/null

              # Install AWS CLI v2
              curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
              unzip -q /tmp/awscliv2.zip -d /tmp/
              /tmp/aws/install --update
              rm -rf /tmp/aws /tmp/awscliv2.zip

              # Download jenkins_slave.sh from S3
              aws s3 cp s3://jenkins-config-terraform/jenkins_slave.sh /root/jenkins_slave.sh --region us-east-1

              chmod +x /root/jenkins_slave.sh
              apt-get install -y dos2unix > /dev/null
              dos2unix /root/jenkins_slave.sh

              bash /root/jenkins_slave.sh > /var/log/jenkins_slave_setup.log 2>&1
          EOF
}*/

# -------------------------------------------------------------------------
# Resource  : Nexus Repository Manager Server
# Purpose   : Provision Nexus Repository Manager (Sonatype) using 
#             remote-exec with a custom setup script.
# OS        : Amazon Linux
# -------------------------------------------------------------------------

/*resource "aws_instance" "nexus" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.nexus.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Nexus-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              
              export PATH=$PATH:/usr/local/bin:/usr/bin:/bin
              
              # Update system
              dnf update -y
              
              # Install prerequisites (do NOT install curl)
              dnf install -y unzip ca-certificates wget
              
              # Install AWS CLI v2
              curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
              unzip -q /tmp/awscliv2.zip -d /tmp/
              /tmp/aws/install --update
              rm -rf /tmp/aws /tmp/awscliv2.zip
              
              # Download Nexus setup script from S3
              aws s3 cp s3://jenkins-config-terraform/nexus-setup.sh /root/nexus-setup.sh --region us-east-1
              
              chmod +x /root/nexus-setup.sh
              dnf install -y dos2unix
              dos2unix /root/nexus-setup.sh
              
              bash /root/nexus-setup.sh > /var/log/nexus_install.log 2>&1
          EOF
}*/

# -------------------------------------------------------------------------
# Resource  : SonarQube Server
# Purpose   : Install and configure SonarQube using a custom shell script.
# OS        : Ubuntu
# -------------------------------------------------------------------------

/*resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.sonarqube.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "SonarQube-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -eux

              export PATH=$PATH:/usr/local/bin:/usr/bin:/bin

              # Install prerequisites
              until apt-get update -y; do sleep 5; done
              apt-get install -y curl unzip ca-certificates > /dev/null

              # Install AWS CLI v2
              curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
              unzip -q /tmp/awscliv2.zip -d /tmp/
              /tmp/aws/install --update
              rm -rf /tmp/aws /tmp/awscliv2.zip

              # Download sonar-setup.sh from S3
              aws s3 cp s3://jenkins-config-terraform/sonar-setup.sh /root/sonar-setup.sh --region us-east-1

              chmod +x /root/sonar-setup.sh
              apt-get install -y dos2unix > /dev/null
              dos2unix /root/sonar-setup.sh

              bash /root/sonar-setup.sh > /var/log/sonar-setup_setup.log 2>&1
          EOF
}*/

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