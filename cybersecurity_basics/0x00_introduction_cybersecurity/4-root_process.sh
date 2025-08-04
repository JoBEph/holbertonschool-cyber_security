#!/bin/bash
argument=$1
ps aux | grep -v "$argument"
