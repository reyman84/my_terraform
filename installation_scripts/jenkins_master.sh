#!/bin/bash
set -eux

# Install only what’s required to fetch from S3
apt-get update -y
apt-get install -y awscli dos2unix

# Download and run actual Jenkins installer from S3
aws s3 cp s3://jenkins-config-terraform/jenkins_master.sh /root/jenkins_master.sh --region us-east-1
chmod +x /root/jenkins_master.sh
dos2unix /root/jenkins_master.sh
bash /root/jenkins_master.sh > /var/log/jenkins_master_setup.log 2>&1
