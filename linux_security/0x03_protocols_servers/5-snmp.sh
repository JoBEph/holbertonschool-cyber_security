#!/bin/bash
grep -hE '^(com2sec|rocommunity)\b.*public' /etc/snmp/snmpd.conf /etc/snmp/snmp.conf /etc/snmp/* 2>/dev/null || true
