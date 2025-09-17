#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {xor}<base64_string>"
    exit 1
fi

if [[ "$1" == \{xor\}* ]]; then
    input="${1#\{xor\}}"
    decoded=$(echo "$input" | base64 --decode 2>/dev/null)
    for ((i=0; i<${#decoded}; i++)); do
        c=$(printf "%d" "'${decoded:$i:1}")
        printf \\$(printf '%03o' $((c ^ 95)))
    done
else
    # pour un simple base64 sans xor
    echo -n "$1" | base64 --decode 2>/dev/null
fi
