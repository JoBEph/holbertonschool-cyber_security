#!/bin/bash
sudo iptables -A INPUT -p tcp -s "$1" --dport 80 -j ACCEPT
