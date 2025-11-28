#!/bin/bash
sudo sort $1 | uniq -c | sort -nr | head -n 1 | awk '{print $2}'
