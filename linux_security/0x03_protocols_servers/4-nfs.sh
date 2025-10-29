#!/bin/bash
showmount -e "$1" | grep -E '\(everyone\)|\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)'
