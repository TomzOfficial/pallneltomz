#!/bin/bash

# =========================
# INSTALL PANEL PTERODACTYL
# =========================

DOMAIN=$1
EMAIL=$2

ADMIN_USER="admin"
ADMIN_PASS="admin123"

echo "==============================="
echo " INSTALLING PTERODACTYL PANEL "
echo "==============================="

sleep 2

# Install panel
curl -s https://pterodactyl-installer.se | bash <<EOF
0
y
$DOMAIN
y
y
$EMAIL
y
y
EOF

echo "================================="
echo " PANEL INSTALLED"
echo "================================="

# Create admin user
cd /var/www/pterodactyl || exit

php artisan p:user:make <<EOF
$ADMIN_USER
$ADMIN_USER
$EMAIL
$ADMIN_PASS
yes
EOF

echo "================================="
echo " ADMIN ACCOUNT CREATED ✅"
echo "================================="

echo ""
echo "====== LOGIN PANEL ======"
echo "URL      : https://$DOMAIN"
echo "EMAIL    : $EMAIL"
echo "PASSWORD : $ADMIN_PASS"
echo "========================="
