#!/bin/bash
yum update -y
yum upgrade -y
yum install java-21-amazon-corretto-devel -y
echo "export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64" >> /etc/profile
echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
source /etc/profile
echo $JAVA_HOME
#java --version
sudo yum install -y git
sudo hostnamectl set-hostname jenkins-slave
sudo reboot
