#!/bin/bash
awk '/ip/ {print $10}' auth.log  | sort | uniq -c | sort -nr | wc -l