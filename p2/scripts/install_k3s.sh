#!/bin/bash
set -e

echo "[INFO] Updating system..."
sudo dnf -y update

echo "[INFO] Installing curl..."
sudo dnf -y install curl

echo "[INFO] Installing K3s (server mode)..."
curl -sfL https://get.k3s.io | sh -

# Wait until K3s config file exists (install complete)
echo "[INFO] Waiting for K3s to install..."
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
    echo "K3s not fully installed yet... waiting 5 seconds"
    sleep 5
done
echo "[INFO] K3s installation detected."

# Wait for Kubernetes API to be ready
echo "[INFO] Waiting for K3s API to be ready..."
until sudo /usr/local/bin/k3s kubectl get nodes >/dev/null 2>&1; do
    echo "K3s API not ready yet... waiting 5 seconds"
    sleep 5
done
echo "[INFO] K3s API is ready."

# Setup kubectl for current user
echo "[INFO] Configuring kubectl for non-root user..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy the applications
echo "[INFO] Deploying applications..."
kubectl apply -f /vagrant/confs/

echo "[INFO] All applications deployed successfully!"
