#!/bin/bash
find "$1" -type f -size 0 -exec chmod 777 {} \; -exec ls -l {} \;
