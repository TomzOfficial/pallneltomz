#!/bin/bash
set -e

NODE_DOMAIN=$1
PANEL_DOMAIN=$2
PANEL_TOKEN=$3

echo "🚀 INSTALLING PTERODACTYL WINGS..."

# ============================
# INSTALL DEPENDENCIES
# ============================
apt update -y
apt install -y curl wget sudo tar unzip apt-transport-https ca-certificates gnupg lsb-release

# ============================
# INSTALL DOCKER
# ============================
curl -fsSL https://get.docker.com | bash
systemctl enable docker
systemctl start docker

# ============================
# INSTALL WINGS
# ============================
mkdir -p /etc/pterodactyl
cd /etc/pterodactyl

curl -L -o wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x wings

# ============================
# CONFIGURATION
# ============================
cat > /etc/pterodactyl/config.yml <<EOF
debug: false
uuid: $(uuidgen)
token_id: "$PANEL_TOKEN"
token: "$PANEL_TOKEN"
api:
  host: 0.0.0.0
  port: 8080
  ssl:
    enabled: false
system:
  data: /var/lib/pterodactyl
  sftp:
    bind_address: 0.0.0.0
    bind_port: 2022
  crash_detection:
    enabled: true
allowed_mounts: []
remote: https://$PANEL_DOMAIN
EOF

# ============================
# SYSTEMD SERVICE
# ============================
cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings.pid
ExecStart=/etc/pterodactyl/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable wings
systemctl start wings

echo "======================================"
echo " ✅ NODE INSTALLED SUCCESSFULLY"
echo "======================================"
echo " 🌐 Node Domain : $NODE_DOMAIN"
echo " 🔌 Port        : 8080"
echo " 📦 Wings       : Active"
echo "======================================"
