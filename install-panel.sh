#!/bin/bash
set -e

DOMAIN=$1
EMAIL=$2

ADMIN_USER="admin"
ADMIN_PASS="admin123"

echo "== INSTALL PTERODACTYL PANEL =="

apt update -y
apt install -y curl wget sudo unzip git mariadb-server nginx \
php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-mbstring \
php8.1-xml php8.1-curl php8.1-zip redis-server

systemctl enable nginx mariadb redis-server
systemctl start nginx mariadb redis-server

mysql -u root <<EOF
CREATE DATABASE panel;
CREATE USER 'panel'@'127.0.0.1' IDENTIFIED BY 'panelpass';
GRANT ALL PRIVILEGES ON panel.* TO 'panel'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

cd /var/www
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
mkdir -p pterodactyl
tar -xzf panel.tar.gz -C pterodactyl
cd pterodactyl

chmod -R 755 storage bootstrap/cache
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-dev --optimize-autoloader

cp .env.example .env
php artisan key:generate --force
php artisan migrate --seed --force

php artisan p:user:make <<EOF
$EMAIL
$ADMIN_USER
Admin
Panel
$ADMIN_PASS
$ADMIN_PASS
yes
EOF

chown -R www-data:www-data /var/www/pterodactyl

echo "==============================="
echo " PANEL BERHASIL DIINSTALL"
echo " URL  : https://$DOMAIN"
echo " USER : admin"
echo " PASS : admin123"
echo "==============================="
