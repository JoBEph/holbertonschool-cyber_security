#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {xor}<string>"
    exit 1
fi

input="${1#\{xor\}}"

decoded=$(echo "$input" | base64 --decode 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Erreur : Base64 fail."
    exit 1
fi

output=$(python3 - <<EOF
data = "$decoded"
key = 95
print(''.join([chr(ord(c) ^ key) for c in data]), end='')
EOF
)

echo "$output"