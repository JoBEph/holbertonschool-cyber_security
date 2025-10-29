#!/bin/bash
iptables -P INPUT DROP
iptables -A INPUT -p tcp -s $1 --dport 22 -j ACCEPT
