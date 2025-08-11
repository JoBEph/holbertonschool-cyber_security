#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root or with sudo." >&2
	exit 1
fi

last -n 5
#!/bin/bash
sudo wtmpdb last -n 5