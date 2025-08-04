#!/bin/bash
PASSWORD=$(head -c $LENGTH /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')
echo $PASSWORD

