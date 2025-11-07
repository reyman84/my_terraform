#!/bin/bash
set -eux

# System Update
sudo dnf update -y
sudo dnf upgrade -y

# Required Packages
sudo dnf install -y java-21-amazon-corretto-devel git wget unzip dos2unix

# Set JAVA_HOME
JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile
source /etc/profile

echo "JAVA_HOME is set to: $JAVA_HOME"
java --version

# Hostname
sudo hostnamectl set-hostname jenkins-slave
