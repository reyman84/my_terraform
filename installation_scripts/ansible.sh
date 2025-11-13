#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# Run as "root" user
sudo apt-get update -y
sudo apt install -y software-properties-common git openssh-client
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version

# Configure Ansible
cd /etc/ansible
sudo mv ansible.cfg ansible.cfg_bkp
sudo -i -u root bash -c 'ansible-config init --disabled -t all > /etc/ansible/ansible.cfg'
sudo sed -i 's/^;host_key_checking=True/host_key_checking=False/' ansible.cfg

# Set hostname
hostnamectl set-hostname ansible-controller

# Enable password authentication for SSH (required for Jenkins Slave connection)
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/*.conf
systemctl restart ssh

# --- Customize root prompt ---
echo "PS1='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

# --- Customize ubuntu prompt ---
sudo -u ubuntu bash -c 'echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc'

# Clone Vprofile repository
sudo -i -u ubuntu bash -c '
  mkdir -p ~/vprofile &&
  cd ~/vprofile &&
  mkdir -p ~/.ssh &&
  ssh-keyscan github.com >> ~/.ssh/known_hosts &&
  git clone https://github.com/reyman84/ansible.git
'