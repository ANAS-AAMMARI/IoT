#!/bin/bash

set -e

dnf update -y
dnf install -y curl bash sed

# Installe K3s
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Attendre que le fichier de token soit disponible
echo "Attente du node-token..."
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 5
done

# save the token 
mkdir -p /vagrant/k3s
cp /var/lib/rancher/k3s/server/node-token /vagrant/k3s/

echo "✅ K3s Server prêt"
