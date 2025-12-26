#!/bin/bash

# =========================
# CREATE NODE SCRIPT
# =========================

LOCATION="$1"
DESCRIPTION="$2"
DOMAIN="$3"
NODE_NAME="$4"
RAM="$5"
DISK="$6"
LOCID="$7"

cd /var/www/pterodactyl || exit 1

echo "Creating Location..."
php artisan p:location:make <<EOF
$LOCATION
$DESCRIPTION
EOF

echo "Creating Node..."
php artisan p:node:make <<EOF
$NODE_NAME
$DESCRIPTION
$LOCID
https
$DOMAIN
yes
no
no
$RAM
$RAM
$DISK
$DISK
100
8080
2022
/var/lib/pterodactyl/volumes
EOF

echo "================================="
echo " NODE CREATED SUCCESSFULLY ✅"
echo "================================="
