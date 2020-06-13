#!/bin/bash

if [ $# -eq 0 ]; then
	echo "must pass a client name as an arg: add-client.sh new-client"
else
	# To lowercase
	declare -l client_name=$1

	count_clients=$(grep -cw $client_name wg0.conf)
	echo "$count_clients fined clients"
	if [ $count_clients -eq 0 ]; then
		echo "Client with name - $client_name not found"
	else
		start_line=$(grep -xn "#Client-Start: $client_name" wg0.conf | grep -o "[0-9]*")
		end_line=$(grep -xn "#Client-End: $client_name" wg0.conf | grep -o "[0-9]*")
		sed -ie "$start_line,"$end_line"d" /etc/wireguard/wg0.conf
		rm -rf /etc/wireguard/clients/$client_name
		echo "Client with name  - $client_name is deleted"
		wg-quick down wg0
		wg-quick up wg0
		clear
	fi
fi
