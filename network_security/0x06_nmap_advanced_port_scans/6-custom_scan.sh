#!/bin/bash
sudo nmap -p $2 --scanflags URGACKPSHRSTSYNFIN $1 -oN custom_scan.txt $1 >/dev/null 2>&1