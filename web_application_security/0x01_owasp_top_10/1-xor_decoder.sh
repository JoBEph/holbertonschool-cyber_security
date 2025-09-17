#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {xor}<base64_string>"
    exit 1
fi
#
decrypt_password="${1#'{xor}'}"

decrypt=$(echo -n "$decrypt_password" | base64 --decode | tr -d '\0')

if [ $? -ne 0 ]; then
    echo "Erreur : Décrypt Failure."
    exit 1
fi

python3 -c "
import sys
decrypt = '$decrypt'
key = 95
output = ''.join([chr(ord(c) ^ key) for c in decrypt])
print(output)
"