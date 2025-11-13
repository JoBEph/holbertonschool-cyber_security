#!/bin/bash
sudo nmap -p $2 --scanflags ALL $1 > custom_scan.txt 2>&1