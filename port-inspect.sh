#!/usr/bin/env bash

set -euo pipefail
readonly BOLD=$'\e[1m'
readonly DIM=$'\e[2m'
readonly UNDERLINE=$'\e[4m'
RESET=$'\e[0m'
COLOR_MAUVE=$'\e[38;2;203;166;247m'
COLOR_RED=$'\e[38;2;243;139;168m'
COLOR_PEACH=$'\e[38;2;250;179;135m'
COLOR_YELLOW=$'\e[38;2;249;226;175m'
COLOR_GREEN=$'\e[38;2;166;227;161m'
COLOR_SAPPHIRE=$'\e[38;2;116;199;236m'
COLOR_BLUE=$'\e[38;2;137;180;250m'
COLOR_LAVENDER=$'\e[38;2;180;190;254m'

port_arg=${1:-}

function usage() {
	FILENAME=$(basename "$0")
	cat <<EOU >&2
$FILENAME Usage:

$FILENAME --help            Display help
$FILENAME <port>			Check specific port
EOU
}

function main {
	local port=$1
	local found=0

	while IFS= read -r line; do
		found=1
		conn_type=$(awk '{print $1}' <<<"$line")
		local_addr=$(awk '{print $5}' <<<"$line")
		data=$(awk '{print $7}' <<<"$line")
		mapfile -t pids < <(grep -oP 'pid=\K[0-9]+' <<<"$data")

		if ((${#pids[@]} == 0)); then
			printf '\nChecking port %s/%s:\nNo PID info available (insufficient permissions or kernel socket)\nNetwork: %s\n' \
				"$port" "$conn_type" "$local_addr"
			continue
		fi

		for pid in "${pids[@]}"; do
			pid_service=$(ps -o unit= -p "$pid" 2>/dev/null || true)
			pid_service=${pid_service// /}

			if [[ -n $pid_service ]]; then
				service_desc=$(systemctl show "$pid_service" --property=Description 2>/dev/null | cut -d'=' -f2- || true)
				service="Service: $pid_service ($service_desc)"
			else
				service="Service: Unknown"
			fi

			pid_owner=$(ps -p "$pid" -o user= 2>/dev/null || echo "Unknown")
			pid_busy_since=$(LC_ALL=C ps -p "$pid" -o lstart= 2>/dev/null | awk '{print $2, $3, $4}')

			if [[ -r "/proc/$pid/comm" ]]; then
				app=$(cat "/proc/$pid/comm")
			else
				app="Unknown"
			fi

			location=$(which "$app" 2>/dev/null || echo "Not found")
			command=$(ps -p "$pid" -o args= 2>/dev/null || echo "Unknown")

			printf "%s\n" "
${BOLD}${COLOR_MAUVE}Checking port ${port}/tcp:${RESET}

PID: ${COLOR_GREEN}$pid${RESET}
${COLOR_SAPPHIRE}${service}${RESET}
Currently taken by: ${COLOR_PEACH}$app${RESET}
Location: ${COLOR_SAPPHIRE}$location${RESET}
Command: ${COLOR_LAVENDER}$command${RESET}
Network: ${COLOR_YELLOW}$local_addr${RESET}
Owner: ${COLOR_RED}$pid_owner${RESET}
Busy since: ${COLOR_GREEN}${pid_busy_since:-Unknown}${RESET}"

		done
	done < <(sudo ss -tulpn | grep ":$port ")

	if ((found == 0)); then
		printf 'Nothing is listening on port %s\n' "$port" >&2
		return 1
	fi
}

if [[ $port_arg == "--help" || $port_arg == "-h" ]]; then
	usage
	exit 0
fi

if [[ -z $port_arg ]]; then
	read -r -p "Enter port: " port_arg
fi

if [[ -z $port_arg || $port_arg =~ [^0-9] ]]; then
	usage
	exit 1
fi

main "$port_arg"
