#!/bin/bash
grep -q "smtpd_tls_security_level = may" /etc/postfix/main.cf || echo "STARTTLS not configured"
