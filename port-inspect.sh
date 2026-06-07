#!/usr/bin/env bash

set -euo pipefail

port_arg=$1

if [[ ! $port_arg ]]; then
	read -r -p "Enter port: " port
else
	port=$port_arg
fi

function usage() {
	FILENAME=$(basename "$0")
	cat <<EOU >&2
$FILENAME Usage:

$FILENAME --help            Display help
$FILENAME <port>			Check specific port
EOU
}

function main {
	while IFS= read -r line; do
		data=$(printf "%s\n" "$line" | awk '{print $7}')
		addr=$(printf "%s\n" "$line" | awk '{print $6}')
		conn_type=$(printf "%s\n" "$line" | awk '{print $1}')
		pid=$(printf "%s\n" "$data" | grep -oP 'pid=\K[0-9]+')
		pid_service=$(ps -o unit= -p "$pid" 2>/dev/null)
		if [[ $pid_service ]]; then
			service_desc=$(systemctl show "$pid_service" --property=Description | cut -d'=' -f2)
			service="Service: $pid_service ($service_desc)"
		else
			service="Unknown"
		fi
		pid_owner=$(ps -p "$pid" -o user=)
		pid_busy_since=$(LC_ALL=C ps -p "$pid" -o lstart= | awk '{print $2, $3, $4}')
		app=$(cat /proc/"$pid"/comm)
		location=$(which "$app" 2>/dev/null || echo "Not found")
		command=$(ps -p "$pid" -o args=)
		printf "%s\n" "
Checking port $port/$conn_type: 
PID: $pid
$service
Currently taken by: $app
Location: $location
Command: $command
Network: $addr
Owner: $pid_owner
Busy since: $pid_busy_since"
	done < <(sudo ss -tulpn | grep ":$port ")
}

case "$port" in
*[!0-9]*)
	usage
	exit 1
	;;
*)
	main
	exit 1
	;;
esac
