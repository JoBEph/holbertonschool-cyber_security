#!/bin/bash
echo $(head -c $1 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')
