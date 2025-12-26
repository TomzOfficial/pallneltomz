#!/bin/bash
set -e

DOMAIN=$1
EMAIL=$2

ADMIN_USER="admin"
ADMIN_PASS="admin123"

apt update -y
apt install -y curl wget sudo

curl -sSL https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/install.sh -o installer.sh
chmod +x installer.sh

# AUTO INSTALL PANEL
bash installer.sh <<EOF
0
y
$DOMAIN
y
y
$EMAIL
y
y
EOF

cd /var/www/pterodactyl

php artisan p:user:make <<EOF
$EMAIL
$ADMIN_USER
Admin
Panel
$ADMIN_PASS
$ADMIN_PASS
yes
EOF
