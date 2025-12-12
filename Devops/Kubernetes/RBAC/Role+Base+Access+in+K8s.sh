#############################################
# Add User in Kubernetes "Minikube" Cluster #
#############################################

# Step 1. Create Name Space
kubectl create namespace development

# Step 2. Create private key and a CSR (Certificate Signing Request) for DevUser
cd ${HOME}/.kube
openssl genrsa -out DevUser.key 2048
openssl req -new -key DevUser.key -out DevUser.csr -subj "/CN=DevUser/O=development"

# The common name (CN) of the subject will be used as username for authentication request. 
# The organization field (O) will be used to indicate group membership of the user.

# Step 3. Provide CA keys of Kubernetes cluster to generate the certificate
openssl x509 -req -in DevUser.csr -CA ${HOME}/.minikube/ca.crt -CAkey ${HOME}/.minikube/ca.key -CAcreateserial -out DevUser.crt -days 45

# Step 4. Get Kubernetes Cluster Config
kubectl config view

# Step 5. Add the user in the Kubeconfig file.
kubectl config set-credentials DevUser --client-certificate ${HOME}/.kube/DevUser.crt --client-key ${HOME}/.kube/DevUser.key

# Step 6. Get Kubernetes Cluster Config
kubectl config view

# Step 7. Add a context in the config file, that will allow this user (DevUser) to access the development namespace in the cluster.
kubectl config set-context DevUser-context --cluster=minikube --namespace=development --user=DevUser

#################################
# Create a Role for the DevUser #
#################################

# Step 1. Test access by attempting to list pods.
kubectl get pods --context=DevUser-context 

# Step 2. Create a role resource using below manifest
#vi pod-reader-role.yml

# Step 3. Create the role
kubectl apply -f pod-reader-role.yml

# Step 4. Verify Role
kubectl get role -n development

#####################################
# Bind the Role to the dev User and #
# Verify Your Setup Works           #
#####################################
# Step 1. Create the RoleBinding spec file
#vi pod-reader-rolebinding.yml

# Step 2. Create Role Binding
kubectl apply -f pod-reader-rolebinding.yml

# Step 3. Test access by attempting to list pods.
kubectl get pods --context=DevUser-context

# Permissions for the certificate and key
chown ubuntu:ubuntu /home/ubuntu/.kube/DevUser.key
chmod 600 /home/ubuntu/.kube/DevUser.key

chown ubuntu:ubuntu /home/ubuntu/.kube/DevUser.crt
chmod 600 /home/ubuntu/.kube/DevUser.crt

# Step 4. Create Pod 
kubectl run nginx --image=nginx --context=DevUser-context
# Note: 
# DevUser should not be able to create pods in the development namespace
# According to the configured Role and RoleBinding, DevUser only has permission to get, watch, and list pods.