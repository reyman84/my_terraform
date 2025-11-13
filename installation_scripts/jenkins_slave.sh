#!/bin/bash

# Update system
apt update -y
apt install -y fontconfig ca-certificates apt-transport-https curl unzip

# Install Java 21
apt install -y openjdk-21-jdk
java -version

# Set JAVA_HOME globally
echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' | sudo tee -a /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile

# Apply JAVA_HOME for current session
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Set hostname
hostnamectl set-hostname jenkins-slave

# Enable password authentication for SSH (required for Jenkins Slave connection)
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/*.conf
systemctl restart ssh

# Create Jenkins home directory with permissions
mkdir -p /var/lib/jenkins
chown -R ubuntu:ubuntu /var/lib/jenkins
sudo chmod 1777 /var/lib/jenkins

# Format and mount /tmp disk
mkfs.ext4 -F /dev/xvdf
mkdir -p /tmp
mount /dev/xvdf /tmp
echo "/dev/xvdf /tmp ext4 defaults,nofail 0 2" >> /etc/fstab
chmod 1777 /tmp

# --- Customize root prompt ---
echo "PS1='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

# --- Customize ubuntu prompt ---
sudo -u ubuntu bash -c 'echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc'
