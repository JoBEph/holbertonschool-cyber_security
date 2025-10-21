#!/bin/bash
john --wordlist=/usr/share/wordlists/rockyou.txt --format=nt "$1"; john --show --format=nt "$1" > 5-password.txt
