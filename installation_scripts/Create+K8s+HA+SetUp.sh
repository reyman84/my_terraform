#!/bin/bash

# 1 Disable Swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 2 Install Basic Dependencies
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg

# 3 Install containerd (Container Runtime)
sudo apt install -y containerd

# Create containerd config:
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Enable systemd cgroup driver:
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

#Restart containerd:
sudo systemctl restart containerd
sudo systemctl enable containerd

# 4 Enable Kernel Modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

#Load modules:
sudo modprobe overlay
sudo modprobe br_netfilter

# 5 Set Required sysctl Params
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

#Apply settings:
sudo sysctl --system

# 6 Install Kubernetes Packages
#(Kubernetes repo for v1.29 — matches your master node)
# Add key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add repo:
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install binary components:
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 11. Add colorful prompt for root and ubuntu user
echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc
sudo -u ubuntu bash -c 'echo "PS1=\"\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;35m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ \"" >> ~/.bashrc'

  ##############################################################################
  # (Note: This is only performed on the Control Plane Node)                   #
  # Initialize the Kubernetes cluster on the control plane node using kubeadm  #
  ##############################################################################

# hostnamectl set-hostname k8s-master-node
# sudo kubeadm init --pod-network-cidr 192.168.0.0/16

# Set kubectl access:
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

# kubeadm token create --print-join-command

# kubeadm token list

