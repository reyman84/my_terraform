                                             #################################################
                                             # Steps to upgrade Kubernetes from 1.28 to 1.29 #
                                             #################################################

# Drain from master node
kubectl drain <<< Node Name >>> --ignore-daemonsets

############################################################################
# Steps 1 to 3 are performed on all nodes (Control Plane and Worker Nodes) #
############################################################################

# Step 1: Add Kubernetes 1.29 repository first
mkdir -p /etc/apt/keyrings/

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-1-29.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-1-29.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

# Step 2: Confirm 1.29 versions
apt-cache madison kubeadm

# Step 3: Install the exact version (example)
apt-get install -y --allow-change-held-packages kubeadm=1.29.2-1.1

#################################### Upgrade the control plane nodes ####################################
kubeadm upgrade plan v1.29.2
kubeadm upgrade apply v1.29.2

apt-get install -y --allow-change-held-packages kubelet=1.29.2-1.1 kubectl=1.29.2-1.1
systemctl daemon-reload
systemctl restart kubelet


#################################### Upgrade the worker nodes ####################################
kubeadm upgrade node
apt-get install -y --allow-change-held-packages kubelet=1.29.2-1.1 kubectl=1.29.2-1.1
systemctl daemon-reload
systemctl restart kubelet
