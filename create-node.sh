#!/bin/bash

NODE_DOMAIN=$1

cd /var/www/pterodactyl

php artisan p:location:make <<EOF
Singapore
Auto Node
EOF

php artisan p:node:make <<EOF
Node-1
Auto Node
1
https
$NODE_DOMAIN
yes
no
no
4096
4096
20000
20000
100
8080
2022
/var/lib/pterodactyl/volumes
EOF
