#!/bin/bash
awk '/firewall/ {print}' auth.log | wc -l