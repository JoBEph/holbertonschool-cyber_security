#!/bin/bash
sudo nmap -sW -sV --reason --exclude-ports $3 $1 -p $2