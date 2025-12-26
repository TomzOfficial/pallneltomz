#!/bin/bash

# =========================
# INSTALL PANEL PTERODACTYL
# =========================

DOMAIN=$1
EMAIL=$2

echo "==============================="
echo " INSTALLING PTERODACTYL PANEL "
echo "==============================="

sleep 2

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
echo " PANEL INSTALLATION COMPLETED ✅ "
echo "================================="
