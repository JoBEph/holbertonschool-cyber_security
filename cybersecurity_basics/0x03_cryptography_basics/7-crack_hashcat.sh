#!/bin/bash
hashcat -m 0 -a 0 -o 7-password.txt "$1" /usr/share/wordlists/rockyou.txt