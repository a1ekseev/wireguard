#!/bin/bash

echo "Update, Upgrade and install wireguard"
apt install wireguard  -y && \
modprobe wireguard

echo "Generate keys"
wg genkey | tee /etc/wireguard/server_private_key | wg pubkey > /etc/wireguard/server_public_key
server_private_key=$(cat /etc/wireguard/server_private_key)

echo "Create config wg0.conf"
cat wg0-server.example | sed -e 's|:PRIVATE_KEY:|'"$server_private_key"'|' > /etc/wireguard/wg0.conf

wg-quick up wg0 && systemctl enable wg-quick@wg0
echo "Wireguard server installed and started"
