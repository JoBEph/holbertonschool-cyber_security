#!/bin/bash
sudo nmap -sM -v --reason --open -p 21,22,23,80,443 $1