#!/bin/bash

set -e

# Met à jour les paquets et installe curl
dnf update -y
dnf install -y curl

# Attendre que le token du serveur soit disponible dans le dossier partagé
echo "Attente du token du serveur..."
while [ ! -f /vagrant/k3s/node-token ]; do
    sleep 10
done

# Lire le token et définir l'URL du serveur
K3S_TOKEN=$(cat /vagrant/k3s/node-token)
K3S_URL="https://192.168.56.110:6443"
INSTALL_K3S_EXEC="--node-ip=192.168.56.111"

# Installer l'agent K3s avec les variables d’environnement nécessaires
curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN INSTALL_K3S_EXEC=$INSTALL_K3S_EXEC sh -
echo "✅ K3s Worker prêt"