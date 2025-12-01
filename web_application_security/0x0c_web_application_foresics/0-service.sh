#!/bin/bash
grep -E "sshd" auth.log | awk '{print $6}' | sort | uniq -c | sort -nr
