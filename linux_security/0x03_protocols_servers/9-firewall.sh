#!/bin/bash
iptables -P INPUT DROP 
iptables -A INPUT -s $1 -p tcp --dport 22 -j ACCEPT
