# Privilege Escalation: Security Shells - 0x00 What the Shell

This project explores techniques for bypassing restrictions (Blacklist Bypass) in restricted Shell environments. The goal is to read the contents of sensitive files when standard tools and certain characters are forbidden.

## Task 0: Escape the Blacklist

- **Target Machine**: cyber shell 0x01 task2
- **Username**: `ssh user@ YOUR _ CONTAINER _ IP`
- **Password**: `user`
- **Target**: `/home/user/flag`

### Objective
Read the `/home/user/flag` file despite a blacklist of commands (`cat`, `grep`, `vi`, etc.) and the prohibition of directly naming the file.

### Major Restrictions
- **Forbidden commands**: `bash`, `sh`, `grep`, `vi`, `find`, `awk`, etc.
- **Forbidden characters**: `|`, `-`, `{}`, and loops (`for`, `while`)

### Solution
Using the `more` command (not banned) combined with wildcards (`?`) to avoid directly naming the "flag" file.

**Command used:**
```bash
more /home/user/fla??
```
<img width="876" height="470" alt="Screenshot 2026-03-03 101342" src="https://github.com/user-attachments/assets/fb6ef38c-3a84-4df7-9cb8-bff83b7f3b6e" />

## Task 1: Bypassing Blacklist & No Spaces

- **Target Machine**: cyber shell 0x01 task3
- **Username**: `ssh user@ YOUR _ CONTAINER _ IP`
- **Password**: `user`
- **Target**: `/home/user/flag`

### Objective
Retrieve the flag on an even more restrictive machine where wildcards and spaces are forbidden.

### Major Restrictions
- All restrictions from Task 0
- **Forbidden special characters**: `|`, `-`, `+`, `*`, `?`
- **Spaces banned**: `' '` is forbidden

### Solution
To bypass the space restriction, we use the `${IFS}` environment variable (Internal Field Separator) which is interpreted by the shell as a delimiter (space by default).

**Command used:**
```bash
more${IFS}/home/user/flag
```
