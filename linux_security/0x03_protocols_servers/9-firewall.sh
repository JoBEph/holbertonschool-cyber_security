#!/bin/bash
iptables -A INPUT -j DROP
iptables -A INPUT -p tcp --dport ssh -j ACCEPT