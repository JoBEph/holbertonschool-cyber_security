#!/bin/bash
awk '/Accepted/ {print $11}' auth.log  | sort | uniq -c | sort -nr | wc -l