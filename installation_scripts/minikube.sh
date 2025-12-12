#!/bin/bash

# 1. Remove old Docker versions (if any)
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# 2. Update system and install dependencies (Required for Docker installation)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 3. Add official Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4. Add official Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
docker --version

# 6. Install kubectl (Kubernetes CLI)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Move kubectl binary to PATH
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# 7. Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version

# 8. Install conntrack (required for Kubernetes)
sudo apt install -y conntrack

# 9. Create/prepare ubuntu user for Minikube
adduser ubuntu                  # Creates user if not exist (ignore if already exists)
usermod -aG sudo ubuntu
usermod -aG docker ubuntu       # Needed to run Docker without sudo

# 10. Start Minikube as a non-root user (Kubernetes requires non-root for Docker driver)
sudo -u ubuntu bash -c 'minikube start --driver=docker'

# 11. Add colorful prompt for root and ubuntu user
echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc
sudo -u ubuntu bash -c 'echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc'

# 12. Set hostname to k8s-minikube
sudo hostnamectl set-hostname k8s-minikube