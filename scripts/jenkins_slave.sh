#!/bin/bash
set -eux

echo "=== Detecting Operating System ==="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS: /etc/os-release missing"
    exit 1
fi

echo "Detected OS: $OS"

########################################
# ✅ Ubuntu (20.04 / 22.04 / 24.04)
########################################
if [[ "$OS" == "ubuntu" ]]; then
    echo "=== Setting up Jenkins Slave on Ubuntu ==="

    apt update -y
    apt upgrade -y

    # Install required software
    apt install -y openjdk-21-jdk git curl wget

    # Set JAVA_HOME
    JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
    echo "export JAVA_HOME=$JAVA_HOME" | tee -a /etc/profile
    echo 'export PATH=$JAVA_HOME/bin:$PATH' | tee -a /etc/profile
    source /etc/profile

    echo "Java Installed: $JAVA_HOME"
    hostnamectl set-hostname jenkins-slave

    echo "=== Ubuntu Jenkins Slave setup DONE ==="
    exit 0
fi

########################################
# ✅ Amazon Linux 2
########################################
if [[ "$OS" == "amzn" ]]; then
    echo "=== Setting up Jenkins Slave on Amazon Linux 2 ==="

    yum update -y
    yum install -y java-21-amazon-corretto-devel git curl wget

    JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
    source /etc/profile

    echo "Java Installed: $JAVA_HOME"
    hostnamectl set-hostname jenkins-slave

    echo "=== Amazon Linux 2 Jenkins Slave setup DONE ==="
    exit 0
fi


########################################
# ✅ Amazon Linux 2023 (AL2023)
########################################
if [[ "$OS" == "alinux" || "$OS" == "amazon" ]]; then
    echo "=== Setting up Jenkins Slave on Amazon Linux 2023 ==="

    dnf update -y
    dnf install -y java-21-amazon-corretto-devel git curl wget

    JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto.x86_64"
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
    source /etc/profile

    echo "Java Installed: $JAVA_HOME"
    hostnamectl set-hostname jenkins-slave

    echo "=== Amazon Linux 2023 Jenkins Slave setup DONE ==="
    exit 0
fi


########################################
# ❌ Unknown OS
########################################
echo "Unsupported OS: $OS"
exit 1