#!/bin/bash
sudo nmap -p $2 --scanflags URGACKPSHRSTSYNFIN $1 > custom_scan.txt 2>&1