#!/bin/bash
sudo sed -n '/^[[:space:]]*#/d;/^[[:space:]]*$/d;p' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
