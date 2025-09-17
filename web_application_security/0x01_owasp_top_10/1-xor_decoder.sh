#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {xor}<string>"
    exit 1
fi

decrypt_password="${1#'{xor}'}"

decrypt=$(echo -n "$decrypt_password" | base64 --decode 2>/dev/null | tr -d '\0')

if [ $? -ne 0 ]; then
    echo "Erreur : Décodage Base64 échoué."
    exit 1
fi

python3 -c "
decrypt = '$decrypt'
key = 95
output = ''.join([chr(ord(c) ^ key) for c in decrypt])
print(output, end='')
"