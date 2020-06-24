#!/bin/bash

if [ $# -eq 0 ]; then
	echo "must pass a client name as an arg: add-client.sh new-client"
else
	# To lowercase
	declare -l client_name=$1

	count_clients=$(grep -cw $client_name wg0.conf)
	echo "$count_clients fined clients"

	if [ $count_clients -eq 0 ]; then
		echo "Creating client config for: $client_name"
		mkdir -p /etc/wireguard/clients/$client_name
		wg genkey >/etc/wireguard/clients/$client_name/private-$client_name
		wg pubkey >/etc/wireguard/clients/$client_name/public-$client_name
		wg genpsk >/etc/wireguard/clients/$client_name/preshared-$client_name

		preshared_key=$(cat /etc/wireguard/clients/$client_name/preshared-$client_name)
		client_public_key=$(cat /etc/wireguard/clients/$client_name/public-$client_name)
		client_private_key=$(cat /etc/wireguard/clients/$client_name/private-$client_name)
		server_ip=$(curl ifconfig.me/ip)
		server_public_key=$(cat /etc/wireguard/server_public_key)

		ip="10.8.0."$(expr $(cat /etc/wireguard/last-ip | tr "." " " | awk '{print $4}') + 1)
		echo "Set IP $ip"

		cat /etc/wireguard/wg0-client.example | sed -e 's/:CLIENT_IP:/'"$ip"'/' |
			sed -e 's|:PRESHARED_KEY:|'"$preshared_key"'|' |
			sed -e 's|:CLIENT_PRIVATE_KEY:|'"$client_private_key"'|' |
			sed -e 's|:SERVER_PUBLIC_KEY:|'"$server_public_key"'|' |
			sed -e 's|:SERVER_ADDRESS:|'"$server_ip"'|' >/etc/wireguard/clients/$client_name/wg0.conf
		echo "Created config"

		echo "Adding Pear"
		echo -e "\n#Client-Start: $client_name" >>/etc/wireguard/wg0.conf
		cat wg0-server-client.example | sed -e 's/:CLIENT_IP:/'"$ip"'/' |
			sed -e 's|:PRESHARED_KEY:|'"$preshared_key"'|' |
			sed -e 's|:CLINET_PUBLIC_KEY:|'"$client_public_key"'|' >>/etc/wireguard/wg0.conf
		echo -e "#Client-End: $client_name" >>/etc/wireguard/wg0.conf

		echo $ip >/etc/wireguard/last-ip
		#tar czvf clients/$client_name.tar.gz clients/$client_name
		#echo "Adding peer to hosts file"
		#echo $ip" "$client_name | sudo tee -a /etc/hosts
		echo "Restart wg0 interface"
		wg-quick down wg0
		wg-quick up wg0
		clear
		echo "Successful client added: $client_name"
		#qrencode -t ansiutf8 < clients/$client_name/wg0.conf
	else
		echo "Client with name $client_name exist"
	fi
fi
