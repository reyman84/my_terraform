#!/bin/bash
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade -y
yum install java-21-amazon-corretto-devel -y
yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
#systemctl status jenkins
echo "export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64" >> /etc/profile
echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
source /etc/profile
echo $JAVA_HOME
#java --version
sudo yum install -y git
sudo hostnamectl set-hostname jenkins-master