#!/bin/bash
groupadd "$1"
chown :"$1" "$2"
chmod 750 "$2"
ls -l "$2" > /dev/null