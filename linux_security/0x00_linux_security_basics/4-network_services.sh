#!/bin/bash
sudo netstat -tunlp | grep -E 'LISTEN|udp' | grep "$1"

