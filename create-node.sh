#!/bin/bash
set -e

NODE_DOMAIN=$1

apt install -y docker.io
systemctl enable docker
systemctl start docker

mkdir -p /etc/pterodactyl
cd /etc/pterodactyl

curl -L https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -o wings
chmod +x wings

echo "Node siap, lanjutkan setup lewat panel"
