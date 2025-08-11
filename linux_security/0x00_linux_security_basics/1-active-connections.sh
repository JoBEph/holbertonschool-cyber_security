#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root or with sudo." >&2
	exit 1
fi

printf "%-8s %-8s %-8s %-22s %-22s %-40s\n" "State" "Recv-Q" "Send-Q" "Local Address:Port" "Peer Address:Port" "Process"

ss -tanp | awk 'NR>1 {
	state=$1;
	recvq=$2;
	sendq=$3;
	local=$4;
	peer=$5;
	proc="";
	for (i=6; i<=NF; i++) proc=proc $i " ";
	printf "%-8s %-8s %-8s %-22s %-22s %-40s\n", state, recvq, sendq, local, peer, proc;
}'
