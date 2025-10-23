#!/bin/bash
groupadd -f "$1"
chgrp "$1" "$2"
chmod 750 "$2"