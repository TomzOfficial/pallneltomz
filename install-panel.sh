#!/bin/bash

DOMAIN=$1
EMAIL=$2

ADMIN_USER="admin$(date +%s)"
ADMIN_PASS=$(openssl rand -base64 10)

echo "== INSTALLING PANEL =="

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

cd /var/www/pterodactyl || exit

php artisan p:user:make <<EOF
$EMAIL
$ADMIN_USER
Admin
Panel
$ADMIN_PASS
$ADMIN_PASS
yes
EOF

echo "============================="
echo "PANEL INSTALLED SUCCESSFULLY"
echo "URL  : https://$DOMAIN"
echo "USER : $ADMIN_USER"
echo "PASS : $ADMIN_PASS"
echo "============================="
