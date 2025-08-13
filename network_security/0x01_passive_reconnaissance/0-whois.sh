#!/bin/bash
whois $1 | awk -F': ' '/Registrant|Admin|Tech/ {s=$1} s && $1 ~ /Name|Organization|Street|City|State\/Province|Postal Code|Country|Phone|Phone Ext:|Fax|Fax Ext:|Email/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print s" "$1","$2}' > $1.csv
