#!/bin/bash
find / -xdev -type d -perm -o+w -print -exec chmod 0755 {} \; 2>/dev/null
