#!/bin/bash

# Update system
sudo apt update -y

# Required dependencies
sudo apt install -y fontconfig ca-certificates apt-transport-https curl

# Install OpenJDK 21 (JDK, not JRE — Jenkins needs tools.jar/javac)
sudo apt install -y openjdk-21-jdk

# Verify Java
java -version

# Create keyrings directory
sudo mkdir -p /etc/apt/keyrings

# Download Jenkins GPG key
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update & install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins --no-pager

# Set JAVA_HOME permanently
JAVA_HOME_PATH="/usr/lib/jvm/java-21-openjdk-amd64"

if ! grep -q "JAVA_HOME" /etc/profile; then
    echo "export JAVA_HOME=$JAVA_HOME_PATH" | sudo tee -a /etc/profile
    echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile
fi

# Apply profile changes
source /etc/profile

echo "✅ Jenkins Installation Completed Successfully"
