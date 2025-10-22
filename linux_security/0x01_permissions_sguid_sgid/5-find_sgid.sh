#!/bin/bash
find "$1" -type f -perm /2000 -exec ls -l {} \; | awk '{print $NF}'