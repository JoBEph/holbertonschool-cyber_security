#!/bin/bash
sudo grep -oP "http://[a-zA-Z0-9.-]+(:[0-9]+)?(/[a-zA-Z0-9._%+-]*)*" $1 | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}'
