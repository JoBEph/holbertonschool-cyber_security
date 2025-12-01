#!/bin/bash
tail -1000 auth.log | grep 'Success' | head -1 | awk '{print $9}'