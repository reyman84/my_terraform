#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# Run as "root" user
sudo apt-get update -y
sudo apt install -y software-properties-common git openssh-client
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
ansible --version
chmod 400 /home/ubuntu/clientkey
#cd /etc/ansible
#sudo mv ansible.cfg ansible.cfg_bkp
#sudo -i -u root bash -c 'ansible-config init --disabled -t all > /etc/ansible/ansible.cfg'
#sudo sed -i 's/^;host_key_checking=True/host_key_checking=False/' ansible.cfg
   
#sudo -i -u ubuntu bash -c '
#  mkdir -p ~/vprofile &&
#  cd ~/vprofile &&
#  mkdir -p ~/.ssh &&
#  ssh-keyscan github.com >> ~/.ssh/known_hosts &&
#  git clone https://github.com/reyman84/ansible.git
#'