#!/bin/bash
find / -type d -perm -0002 -exec chmod o-w {} + 2>/dev/null
