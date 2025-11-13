#!/bin/bash
sudo nmap -sM -vv --reason --open -p ftp,ssh,telnet,http,https $1