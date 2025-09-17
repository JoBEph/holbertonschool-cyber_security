#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {xor}<base64_string> or <base64_string>"
    exit 1
fi

python3 - "$1" << 'EOF'
import sys, base64
arg = sys.argv[1]
if arg.startswith('{xor}'):
    b64 = arg[5:]
    try:
        data = base64.b64decode(b64)
    except Exception:
        sys.exit(1)
    key = 95
    print(''.join(chr(b ^ key) for b in data), end='')
else:
    try:
        data = base64.b64decode(arg)
        print(data.decode(errors='replace'), end='')
    except Exception:
        sys.exit(1)
EOF
