#!/bin/bash
set -e

DOMAIN=$1
EMAIL=$2

ADMIN_USER="admin"
ADMIN_PASS="admin123"
DB_PASS=$(openssl rand -hex 12)

echo "🚀 Installing Pterodactyl Panel..."
sleep 2

# ==============================
# SYSTEM
# ==============================
apt update -y
apt install -y curl wget sudo git unzip nginx mariadb-server \
php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-mbstring \
php8.1-xml php8.1-curl php8.1-zip php8.1-bcmath redis-server

systemctl enable nginx mysql redis-server
systemctl start nginx mysql redis-server

# ==============================
# DATABASE
# ==============================
mysql -u root <<EOF
CREATE DATABASE panel;
CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

# ==============================
# DOWNLOAD PANEL
# ==============================
cd /var/www
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
mkdir -p pterodactyl
tar -xzf panel.tar.gz -C pterodactyl
cd pterodactyl

chmod -R 755 storage bootstrap/cache

# ==============================
# INSTALL DEPENDENCY
# ==============================
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-dev --optimize-autoloader

cp .env.example .env
php artisan key:generate --force

# ==============================
# CONFIG
# ==============================
php artisan p:environment:setup --author="$EMAIL" --url="https://$DOMAIN" \
--timezone="Asia/Jakarta" --cache="redis" --session="redis" --queue="redis"

php artisan p:environment:database \
--host=127.0.0.1 \
--port=3306 \
--database=panel \
--username=ptero \
--password=$DB_PASS

php artisan migrate --seed --force

# ==============================
# CREATE ADMIN
# ==============================
php artisan p:user:make <<EOF
$ADMIN_USER
$ADMIN_USER
$EMAIL
$ADMIN_PASS
yes
EOF

# ==============================
# PERMISSION
# ==============================
chown -R www-data:www-data /var/www/pterodactyl
php artisan queue:restart

# ==============================
# NGINX
# ==============================
cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx

# ==============================
# DONE
# ==============================
echo "=================================="
echo " ✅ PANEL INSTALLED SUCCESSFULLY"
echo "=================================="
echo " 🌐 URL      : http://$DOMAIN"
echo " 👤 USER     : admin"
echo " 🔑 PASS     : admin123"
echo "=================================="
