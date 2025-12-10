# -------------------------------------------------------------------------
# Resource  : Docker Engine Server
# Purpose   : Provision a Docker Engine server with Docker CE, Buildx,
#             and Docker Compose plugin installed through user_data.
# OS        : ubuntu_24
# -------------------------------------------------------------------------
#
# IMPORTANT NOTES:
#
# 1. Docker Compose is designed for SINGLE-NODE deployments only.
#    - You can run multiple containers on a single server,
#      but it cannot manage or orchestrate multiple servers.
#
# 2. To create a MULTI-NODE environment, you must use DOCKER SWARM.
#    - Swarm requires Docker Engine to be installed on each node.
#    - After provisioning, initialize the Swarm on one node:
#         docker swarm init --advertise-addr <manager-private-ip>
#
#    - Get worker join token:
#         docker swarm join-token worker -q
#
#    - Join worker nodes:
#         docker swarm join --token <WORKER_TOKEN> <manager-private-ip>:2377
#
# 3. This Terraform resource only installs Docker Engine.
#    It does NOT automatically join nodes into a Swarm cluster.
#    (Swarm init/join can be added using additional user_data scripts.)
#
# -------------------------------------------------------------------------

/*resource "aws_instance" "docker" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.allow_all.id]

  tags = {
    Name = "Docker-Engine"
  }

  user_data = file("${path.module}/installation_scripts/docker_install.sh")
}*/

# -------------------------------------------------------------------------
# Resource  : Kubernetes Minikube Server
# Purpose   : Provision a single-node Kubernetes cluster for learning and
#             development purposes using Minikube.
# Cluster   : Single-node (control-plane + worker on same instance) 
#             Installs Docker CE, kubectl, conntrack, and Minikube.
# Runtime   : Docker (Minikube --driver=docker)
# OS        : ubuntu_24 (latest LTS) - Requires t3.medium or higher.
# -------------------------------------------------------------------------

/*resource "aws_instance" "k8s-minikube" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.allow_all.id]

  tags = {
    Name = "k8s-minikube"
  }

  user_data = file("${path.module}/installation_scripts/minikube.sh")
}*/

# -----------------------------------------------------------------------------
# Resource  : Kubernetes HA Cluster (Multi-Node)
# Purpose   : Provision a multi-node Kubernetes cluster using kubeadm.
#
# Architecture:
#   - Master Node: kubeadm init executed and Calico CNI installed
#   - Worker Node: joins using kubeadm join command
#
# Installation:
#   - Installs: Docker CE, kubeadm, kubectl, kubelet, containerd
#   - Enables: br_netfilter, required sysctl params
#   - Configures containerd + CRI
#
# Runtime   : containerd (default for Kubernetes 1.29+)
# OS        : Ubuntu 22.04 LTS - t3.medium (Recommended for Control Plane)
#
# Security Groups: - Allows SSH + internal Kubernetes communication
#                  - Access limited to VPC network
# -----------------------------------------------------------------------------

resource "aws_instance" "k8s-HA-cluster" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[2]
  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.allow_all.id]

  tags = {
    Name = "k8s-HA-Master-cluster"
  }

  user_data = file("${path.module}/installation_scripts/Create+K8s+HA+SetUp.sh")
}

# -------------------------------------------------------------------------
# Resource  : Ansible Controller Server
# Purpose   : Launch an Ansible Controller server with Ansible installed
#             via user_data using PPA repository.
# OS        : Ubuntu_24
# Requires  : SSH connection from Controller to Target Nodes
# -------------------------------------------------------------------------

/*resource "aws_instance" "ansible_controller" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "Ansible-Controller"
  }

  user_data = file("${path.module}/installation_scripts/ansible.sh")
}*/

# -------------------------------------------------------------------------
# Resource  : Ansuble Target Node - "ubuntu_24"
# Purpose   : Target node for testing multi-platform automation.
# OS        : ubuntu_24
# Requires  : SSH connection from Controller to Target Nodes
# -------------------------------------------------------------------------

/*resource "aws_instance" "ansible_node_ubuntu_24" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "ansible-node-ubuntu_24"
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
# Purpose   : - Install Jenkins, Java 21, AWS CLI
#             - Restore Jenkins configuration from S3 bucket using IAM role
# OS        : ubuntu_24
# Requires  : SSH connection between Jenkins Master and Slave nodes
# -------------------------------------------------------------------------

/*resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu_24.id
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

  user_data = file("${path.module}/installation_scripts/jenkins_master.sh")
}*/

# -------------------------------------------------------------------------
# Component : Jenkins Slave (Build Agent)
# Purpose   : Provisions Jenkins Build Agent node 
# OS        : Amazon Linux
# Requires  : SSH connection between Jenkins Master and Slave nodes
# -------------------------------------------------------------------------

/*resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu_24.id
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

  user_data = file("${path.module}/installation_scripts/jenkins_slave.sh")
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

  user_data = file("${path.module}/installation_scripts/nexus-setup.sh")
}*/

# -------------------------------------------------------------------------
# Resource  : SonarQube Server
# Purpose   : Install and configure SonarQube using a custom shell script.
# OS        : ubuntu_24
# -------------------------------------------------------------------------

/*resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu_24.id
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

  user_data = file("${path.module}/installation_scripts/sonar-setup.sh")
}*/

# -------------------------------------------------------------------------
# Resource  : Jenkins Ansible Deployment Nodes
# Purpose   : - Creates two nodes (Stage & Prod) for deployment automation.
#             - Used by Jenkins for Deployment pipelines.
# OS        : ubuntu_24
# -------------------------------------------------------------------------

# Create two Jenkins Ansible deployment nodes for stage and prod environments
/*resource "aws_instance" "jenkins_ansible_deployment" {
  count = 2
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu_24.id
  key_name               = aws_key_pair.devops_project.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "ansible_nodes-${count.index + 1}"
  }
}*/