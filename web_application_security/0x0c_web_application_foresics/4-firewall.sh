#!/bin/bash
awk '/iptables/' auth.log | grep 'A INPUT' | wc -l | sort -u