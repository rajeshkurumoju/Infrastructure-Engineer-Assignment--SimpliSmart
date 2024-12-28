#!/bin/bash

# Set KUBECONFIG path if not already set
export KUBECONFIG=/path/to/kubeconfig

# kubectl Installation
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl  -----Make the kubectl binary executable
sudo mv ./kubectl /usr/local/bin/kubectl

# Check kubectl version
kubectl version --client

# eksctl  Installation    
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version


# Install Helm if not already installed
if ! command -v helm &> /dev/null
then
    echo "Helm could not be found. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm is already installed"
fi

# Add KEDA Helm repo and update
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

# Install KEDA
helm install keda kedacore/keda --namespace keda --create-namespace

# Verify KEDA installation
kubectl get pods -n keda
