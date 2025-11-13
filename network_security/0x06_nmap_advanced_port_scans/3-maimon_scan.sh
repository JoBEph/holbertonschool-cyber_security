#!/bin/bash
sudo nmap -sM -v --reason --open -p ftp,ssh,telnet,http,https $1