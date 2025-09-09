#!/bin/bash
set -x

sudo yum update -y
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker

#sudo reboot

# Install Docker Compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.35.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Wait to ensure Docker is up
sleep 10

sudo usermod -aG docker ec2-user

# Clone and run everything as ec2-user in a login shell
sudo -i -u ec2-user bash -c "  
  git clone -b docker https://github.com/reyman84/vprofile-project.git && \
  cd vprofile-project && \
  docker-compose build && \
  docker-compose up -d && \
  docker images && docker ps
 "
