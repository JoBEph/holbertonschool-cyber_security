#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {xor}<string>"
    exit 1
fi

input="${1#\{xor\}}"

decoded=$(echo "$input" | base64 --decode)

for ((i=0; i<${#decoded}; i++)); do
    c=$(printf "%d" "'${decoded:$i:1}")
    printf \\$(printf '%03o' $((c ^ 95)))
done
