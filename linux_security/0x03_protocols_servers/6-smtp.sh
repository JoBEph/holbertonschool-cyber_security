#!/bin/bash
grep -E '^[[:space:]]*smtpd_tls_security_level[[:space:]]*=' /etc/postfix/main.cf 2>/dev/null || echo "STARTTLS not configured"
