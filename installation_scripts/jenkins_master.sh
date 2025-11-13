#!/bin/bash

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

# Set JAVA_HOME globally
echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' | sudo tee -a /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile

# Apply JAVA_HOME for current session
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Install Jenkins repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins

# Download backup (IAM role must be attached!)
aws s3 cp s3://jenkins-config-terraform/jenkins_backup_v1.tar.gz /root/jenkins_backup.tar.gz --region us-east-1

# Restore Jenkins config
systemctl stop jenkins
tar -xzvf /root/jenkins_backup.tar.gz -C / --overwrite
chown -R jenkins:jenkins /var/lib/jenkins
rm /root/jenkins_backup.tar.gz
systemctl start jenkins

# Set hostname
hostnamectl set-hostname jenkins-master

# Enable password authentication for SSH (required for Jenkins Slave connection)
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/*.conf
systemctl restart ssh

# --- Customize root prompt ---
echo "PS1='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

# --- Customize ubuntu prompt ---
sudo -u ubuntu bash -c 'echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc'
