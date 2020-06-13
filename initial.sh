#!/bin/bash

apt update -y && \
apt upgrade -y && \
apt install unzip resolvconf curl qrencode ufw -y && \
sysctl -w net.ipv4.ip_forward=1 && \
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && \
sysctl -w net.ipv6.conf.default.disable_ipv6=1 && \
sysctl -w net.ipv6.conf.lo.disable_ipv6=1 && \

curl -Lo wireguard.zip https://github.com/a1ekseev/wireguard/archive/master.zip

unzip -j wireguard.zip -d /etc/wireguard/

./etc/wireguard/install_server.sh