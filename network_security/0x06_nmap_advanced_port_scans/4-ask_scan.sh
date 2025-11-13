#!/bin/bash
sudo nmap -sA --host-timeout 1000ms --reason -p $2 $1