#!/bin/bash
find "$1" -type f -size 0 -exec chmod 777 {} \;
find "$1" -type f -size 0 -exec ls -l {} \;