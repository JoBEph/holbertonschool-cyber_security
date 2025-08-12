#!/bin/bash
iptables -A INPUT -p tcp --dport 80 -s "$1" -j ACCEPT
