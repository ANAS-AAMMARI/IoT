#!/bin/bash
set -e

echo "[INFO] Updating system..."
sudo dnf update -y

echo "[INFO] Installing required packages..."
sudo dnf install -y curl bash sed

# Install K3s with kubeconfig readable by all users
echo "[INFO] Installing K3s (server mode)..."
curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110 --write-kubeconfig-mode 644

# Wait for the node-token to be available
echo "[INFO] Waiting for K3s node-token..."
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    echo "Node-token not found yet... waiting 5 seconds"
    sleep 5
done
echo "[INFO] Node-token found."

# Save the token for agents
echo "[INFO] Saving node-token to /vagrant/k3s/"
sudo mkdir -p /vagrant/k3s
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/k3s/
sudo chmod 644 /vagrant/k3s/node-token

# Configure kubectl for the current user
echo "[INFO] Setting up kubectl for non-root user..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Create a persistent alias for kubectl
echo "[INFO] Creating alias for 'k'..."
if ! grep -q "alias k='kubectl'" ~/.bashrc; then
    echo "alias k='kubectl'" >> ~/.bashrc
fi

source ~/.bashrc

echo "✅ K3s Server ready and alias 'k' created!"
