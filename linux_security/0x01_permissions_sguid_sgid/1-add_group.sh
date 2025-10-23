#!/bin/bash
groupadd "$1"
chown :"$1" "$2"
chmod u=rwx,g=rx,o= "$2"