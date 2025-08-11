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

# Deploy the applications
echo "[INFO] Deploying applications..."
sudo /usr/local/bin/k3s kubectl apply -f /vagrant/confs/

echo "[INFO] All applications deployed successfully!"
